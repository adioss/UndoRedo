package fr.adioss.undoredo {
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.utils.Timer;

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
        private var m_fakeBlinkCaretTimer:Timer;

        [Bindable]
        public var commands:ArrayCollection = new ArrayCollection();
        [Bindable]
        public var currentIndex:int = 0;

        public function UndoRedo(textArea:TextArea) {
            m_textArea = textArea;
            m_textField = TextField(m_textArea.getTextField());
            m_textArea.addEventListener(Event.CHANGE, onTextAreaChanged);
            m_textArea.addEventListener(KeyboardEvent.KEY_DOWN, onTextAreaKeyDown);
        }

        //region Events

        private function onTextAreaKeyDown(keyboardEvent:KeyboardEvent):void {
            manageKeyboardEvent(keyboardEvent);
        }

        private function onFakeBlinkCaretTimerComplete(event:TimerEvent):void {
            escapeSubstituteCharsOnTextField();
            var currentText:String = m_textArea.getTextField().text;
            var previousText:String = escapeSubstituteChars(m_previousText);
            manageTextDifferences(currentText, StringDifferenceUtils.difference(previousText, currentText));
            m_fakeBlinkCaretTimer.stop();
        }

        private function manageKeyboardEvent(keyboardEvent:KeyboardEvent):void {
            if (isUndoKeyPressed(keyboardEvent)) {
                undo();
            } else if (isRedoKeyPressed(keyboardEvent)) {
                redo();
            } else {
                manageBackspaceOnKeyPressed();
            }
        }

        private function onTextAreaChanged(event:Event):void {
            resetFakeBlinkCaretTimer();
        }

        private function resetFakeBlinkCaretTimer():void {
            if (m_fakeBlinkCaretTimer != null) {
                m_fakeBlinkCaretTimer.stop();
            }
            m_fakeBlinkCaretTimer = new Timer(500);
            m_fakeBlinkCaretTimer.addEventListener(TimerEvent.TIMER, onFakeBlinkCaretTimerComplete);
            m_fakeBlinkCaretTimer.start();
        }

        //endregion

        private function manageTextDifferences(currentText:String, difference:Difference):void {
            if (difference != null && difference.content != "") {
                if (difference.type == Difference.ADDITION_DIFFERENCE_TYPE) { // addition management
                    if (difference.content.length == 1) {
                        appendInProcessedWord(difference.content);
                    } else {
                        appendCurrentDifferences(difference);
                    }
                } else { // deletion management
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
            //escapeSubstituteCharsOnTextField();
            var currentText:String = m_textArea.getTextField().text;
            var difference:Difference = StringDifferenceUtils.difference(m_previousText, currentText);
            if (difference != null && isNewLineOrTab(difference.content)) {
                manageTextDifferences(currentText, difference);
            }
        }

        public function undo():void {
            if (currentIndex > 0 || (m_currentProcessedWord != null && m_currentProcessedWord.content.length > 0)) {
                appendCurrentWord();
                currentIndex--;
                var difference:Difference = Difference(commands.getItemAt(currentIndex));
                if (difference.type == Difference.SUBTRACTION_DIFFERENCE_TYPE) {
                    modifyTextAreaContentByUndoOrRedo(difference.content, difference.position, difference.position);
                } else {
                    modifyTextAreaContentByUndoOrRedo("", difference.position, difference.position + difference.content.length);
                }
            }
        }

        public function redo():void {
            if (currentIndex < commands.length) {
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
            modifyTextAreaContent(content, beginIndex, endIndex);
        }

        private function appendCurrentDifferences(difference:Difference):void {
            appendCurrentWord();
            appendDifferenceInCommands(difference);
        }

        private function appendCurrentWord():void {
            if (m_currentProcessedWord != null && m_currentProcessedWord.content != "") {
                var difference:Difference = new Difference(m_currentProcessedWord.initialPosition, m_currentProcessedWord.content,
                                                           Difference.ADDITION_DIFFERENCE_TYPE);
                appendDifferenceInCommands(difference);
                m_currentProcessedWord = null;

            }
        }

        private function appendDifferenceInCommands(difference:Difference):void {
            if (commands.length > currentIndex) {
                commands = new ArrayCollection(commands.toArray().slice(0, currentIndex));
            }
            commands.addItemAt(difference, currentIndex);
            currentIndex++;
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
