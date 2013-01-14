package fr.adioss.undoredo {
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.text.TextField;
    import flash.ui.Keyboard;

    import fr.adioss.undoredo.model.Difference;
    import fr.adioss.undoredo.model.ProcessedWord;

    import mx.collections.ArrayCollection;
    import mx.controls.TextArea;
    import mx.controls.textClasses.TextRange;
    import mx.core.mx_internal;

    public class UndoRedo {
        use namespace mx_internal;

        private var m_previousText:String = "";
        private var m_currentProcessedWord:ProcessedWord;
        private var m_textArea:TextArea;
        private var m_textField:TextField;
        private var m_isChangedByUndoRedoOperation:Boolean = false;
        private var m_isAlreadyManagedByKeyDown:Boolean = false;

        [Bindable]
        public var commands:ArrayCollection = new ArrayCollection();
        [Bindable]
        public var currentIndex:int = 0;

        public function UndoRedo(textArea:TextArea) {
            m_textArea = textArea;
            m_textField = TextField(m_textArea.getTextField());
            m_textArea.addEventListener(Event.CHANGE, onTextAreaChanged);
            m_textArea.addEventListener(KeyboardEvent.KEY_DOWN, onTextAreaKeyDown);
            m_textArea.addEventListener(KeyboardEvent.KEY_UP, onTextAreaKeyUp);
        }

        //region Events

        private function onTextAreaKeyDown(event:KeyboardEvent):void {
            manageKeyboardEvent(event, false);
        }

        private function onTextAreaKeyUp(event:KeyboardEvent):void {
            manageKeyboardEvent(event, true);
        }

        private function manageKeyboardEvent(event:KeyboardEvent, isManageByKeyUp:Boolean):void {
            trace(event);
            if (isManageByKeyUp && !m_isAlreadyManagedByKeyDown || !isManageByKeyUp) {
                if (isUndoKeyPressed(event)) {
                    undo();
                } else if (isRedoKeyPressed(event)) {
                    redo();
                } else if (event.keyCode == Keyboard.BACKSPACE || event.keyCode == Keyboard.DELETE) {
                    m_textArea.callLater(manageBackspaceOnKeyPressed); // line break deletion not detected by text area changes...
                }
            }
            m_isAlreadyManagedByKeyDown = m_isAlreadyManagedByKeyDown && isManageByKeyUp;
        }

        private function onTextAreaChanged(event:Event):void {
            if (!m_isChangedByUndoRedoOperation) {
                escapeSubstituteCharsOnTextField();
                var currentText:String = m_textArea.getTextField().text;
                var previousText:String = escapeSubstituteChars(m_previousText);
                if (currentText != "") {
                    manageTextDifferences(currentText, StringDifferenceUtils.difference(previousText, currentText));
                }
            }
            m_isChangedByUndoRedoOperation = false;
        }

        //endregion

        private function manageTextDifferences(currentText:String, difference:Difference):void {
            if (difference != null && difference.content != "") {
                if (difference.type == Difference.ADDITION_DIFFERENCE_TYPE) { // addition management
                    if (difference.content.length == 1) {
                        if (isNewLineOrTab(difference.content)) {
                            appendCurrentDifferences(difference);
                        } else {
                            appendInProcessedWord(difference.content);
                        }
                    } else {
                        appendCurrentDifferences(difference);
                    }
                } else { // deleton management
                    appendCurrentDifferences(difference);
                }
                m_previousText = currentText;
            }
        }

        private function appendInProcessedWord(content:String):void {
            if (m_currentProcessedWord == null) {
                m_currentProcessedWord = new ProcessedWord(content, getCorrespondingCursorPosition(content, 0));
            } else {
                m_currentProcessedWord.content += content;
            }
        }

        private function manageBackspaceOnKeyPressed():void {
            escapeSubstituteCharsOnTextField();
            var currentText:String = m_textArea.getTextField().text;
            var difference:Difference = StringDifferenceUtils.difference(m_previousText, currentText);
            if (difference != null && isNewLineOrTab(difference.content)) {
                manageTextDifferences(currentText, difference);
            }
        }

        private function undo():void {
            if (currentIndex > 0 || (m_currentProcessedWord != null && m_currentProcessedWord.content.length > 0)) {
                appendCurrentWord();
                m_isChangedByUndoRedoOperation = true;
                currentIndex--;
                var difference:Difference = Difference(commands.getItemAt(currentIndex));
                if (difference.type == Difference.SUBTRACTION_DIFFERENCE_TYPE) {
                    modifyTextAreaContentByUndoOrRedo(difference.content, difference.position, difference.position);
                } else {
                    modifyTextAreaContentByUndoOrRedo("", difference.position, difference.position + difference.content.length);
                }
            }
        }

        private function redo():void {
            if (currentIndex < commands.length) {
                m_isChangedByUndoRedoOperation = true;
                var difference:Difference = Difference(commands.getItemAt(currentIndex));
                if (difference.type == Difference.SUBTRACTION_DIFFERENCE_TYPE) {
                    modifyTextAreaContentByUndoOrRedo("", difference.position, difference.position + difference.content.length);
                } else {
                    modifyTextAreaContentByUndoOrRedo(difference.content, difference.position, difference.position + difference.content.length);
                }
                currentIndex++;
            }
        }

        private function modifyTextAreaContentByUndoOrRedo(content:String, beginIndex:int, endIndex:int):void {
            m_textArea.callLater(modifyTextAreaContent, [content, beginIndex, endIndex]);
        }

        private function appendCurrentDifferences(difference:Difference):void {
            appendCurrentWord();
            append(difference);
        }

        private function append(difference:Difference):void {
            appendItem(difference);
            currentIndex++;
        }

        private function appendCurrentWord():void {
            if (m_currentProcessedWord != null && m_currentProcessedWord.content != "") {
                var difference:Difference = new Difference(m_currentProcessedWord.initialPosition, m_currentProcessedWord.content,
                                                           Difference.ADDITION_DIFFERENCE_TYPE);
                appendItem(difference);
                m_currentProcessedWord = null;
                currentIndex++;
            }
        }

        private function appendItem(difference:Difference):void {
            if (commands.length > currentIndex) {
                commands = new ArrayCollection(commands.toArray().slice(0, currentIndex));
            }
            commands.addItemAt(difference, currentIndex);
        }

        private function modifyTextAreaContent(content:String, beginIndex:int, endIndex:int):void {
            new TextRange(m_textArea, false, beginIndex, endIndex).text = content;
            m_previousText = m_textField.text;
            m_textArea.callLater(setSelectionAndFocus, [endIndex]);

        }

        private function setSelectionAndFocus(focusPosition:int):void {
            m_textArea.selectionBeginIndex = focusPosition + 1;
            m_textArea.selectionEndIndex = focusPosition + 1;
            m_textArea.setFocus();
        }

        private function getCorrespondingCursorPosition(word:String, delta:int = -1):int {
            var caretIndex:int = m_textField.caretIndex;
            return caretIndex - word.length + delta;
        }

        private function escapeSubstituteCharsOnTextField():void {
            var text:String = m_textArea.getTextField().text;
            var substituteCharIndex:int = text.indexOf("\u001A");
            if (substituteCharIndex != -1) {
                m_textArea.getTextField().replaceText(substituteCharIndex, substituteCharIndex + 1, "");
                escapeSubstituteCharsOnTextField();
            }
        }

        private static function escapeSubstituteChars(result:String):String {
            return result.replace(/["\u001A"]+/g, "");
        }

        private static function isUndoKeyPressed(event:KeyboardEvent):Boolean {
            // ctrl + Z
            return (event.ctrlKey && !event.shiftKey && event.charCode == 26) || //mac
                    (event.ctrlKey && !event.shiftKey && event.keyCode == 90);  // windows
        }

        private static function isRedoKeyPressed(event:KeyboardEvent):Boolean {
            // ctrl + shift + Z
            return (event.ctrlKey && event.shiftKey && event.charCode == 26) || // mac
                    (event.ctrlKey && event.shiftKey && event.keyCode == 90); // windows
        }

        private static function isNewLineOrTab(content:String):Boolean {
            return content == "\n" || content == "\t" || content == "\r";
        }
    }
}
