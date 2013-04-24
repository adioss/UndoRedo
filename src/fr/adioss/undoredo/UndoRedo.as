package fr.adioss.undoredo {
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.utils.Timer;

    import fr.adioss.undoredo.model.Difference;
    import fr.adioss.undoredo.model.Operation;

    import mx.collections.ArrayCollection;
    import mx.controls.Button;
    import mx.controls.TextArea;
    import mx.controls.textClasses.TextRange;
    import mx.core.mx_internal;

    public class UndoRedo {
        use namespace mx_internal;

        private static const FAKE_BLINK_CARET_TIMER_DELAY:int = 500;

        private var m_previousText:String = "";
        private var m_textArea:TextArea;
        private var m_textField:TextField;
        private var m_undoButton:Button;
        private var m_redoButton:Button;

        private var m_fakeBlinkCaretTimer:Timer;

        [Bindable]
        private var m_differences:ArrayCollection = new ArrayCollection() /*of Difference*/;
        [Bindable]
        private var m_currentIndex:int = 0;

        public function UndoRedo(textArea:TextArea, undoButton:Button = null, redoButton:Button = null) {
            m_textArea = textArea;
            m_textField = TextField(m_textArea.getTextField());
            m_previousText = m_textField.text;
            m_textArea.addEventListener(Event.CHANGE, onTextAreaChanged);
            m_textArea.addEventListener(KeyboardEvent.KEY_DOWN, onTextAreaKeyDown);
            if (undoButton != null) {
                m_undoButton = undoButton;
                m_undoButton.addEventListener(MouseEvent.CLICK, onUndoButtonClick)
            }
            if (redoButton != null) {
                m_redoButton = redoButton;
                m_redoButton.addEventListener(MouseEvent.CLICK, onRedoButtonClick)
            }
        }

        public function resetContext():void {
            m_differences = new ArrayCollection();
            m_currentIndex = 0;
            m_previousText = m_textField.text;
            if (m_fakeBlinkCaretTimer != null && m_fakeBlinkCaretTimer.running) {
                m_fakeBlinkCaretTimer.removeEventListener(TimerEvent.TIMER, onFakeBlinkCaretTimerComplete);
                m_fakeBlinkCaretTimer.stop();
            }
        }

        public function stopUndoRedo():void {
            m_textArea.removeEventListener(Event.CHANGE, onTextAreaChanged);
            m_textArea.removeEventListener(KeyboardEvent.KEY_DOWN, onTextAreaKeyDown);
            if (m_undoButton != null) {
                m_undoButton.removeEventListener(MouseEvent.CLICK, onUndoButtonClick)
            }
            if (m_redoButton != null) {
                m_redoButton.removeEventListener(MouseEvent.CLICK, onRedoButtonClick)
            }
        }

        //region Events

        private function onTextAreaKeyDown(keyboardEvent:KeyboardEvent):void {
            manageKeyboardEvent(keyboardEvent);
        }

        private function onFakeBlinkCaretTimerComplete(event:TimerEvent):void {
            manageCurrentTypedText();
        }

        private function onTextAreaChanged(event:Event):void {
            resetFakeBlinkCaretTimer();
        }

        private function onUndoButtonClick(event:MouseEvent):void {
            undo();
        }

        private function onRedoButtonClick(event:MouseEvent):void {
            redo();
        }

        //endregion

        private function manageCurrentTypedText():void {
            m_fakeBlinkCaretTimer.stop();
            var currentText:String = m_textArea.getTextField().text;
            var previousText:String = m_previousText;
            manageTextDifferences(currentText, new Difference(StringDifferenceUtils.difference(previousText, currentText)));
        }

        private function manageTextDifferences(currentText:String, differenceToAppend:Difference):void {
            trace("differences avant :" + m_differences.length + " et m_currentIndex:" + m_currentIndex);
            // clean next command before add
            if ((m_differences.length - 1) >= m_currentIndex) {
                var commandCopy:ArrayCollection = new ArrayCollection();
                for (var i:int = 0; i < m_currentIndex; i++) {
                    commandCopy.addItem(m_differences.getItemAt(i) as Difference);
                }
                m_differences = commandCopy;
                m_differences.refresh();
                trace("differences après :" + m_differences.length);
            }
            m_differences.addItem(differenceToAppend);
            m_currentIndex++;
            m_previousText = currentText;
        }

        private function manageKeyboardEvent(keyboardEvent:KeyboardEvent):void {
            if (isUndoKeyPressed(keyboardEvent)) {
                undo();
            } else if (isRedoKeyPressed(keyboardEvent)) {
                redo();
            }
        }

        private function resetFakeBlinkCaretTimer():void {
            if (m_fakeBlinkCaretTimer != null) {
                m_fakeBlinkCaretTimer.stop();
            }
            m_fakeBlinkCaretTimer = new Timer(FAKE_BLINK_CARET_TIMER_DELAY);
            m_fakeBlinkCaretTimer.addEventListener(TimerEvent.TIMER, onFakeBlinkCaretTimerComplete);
            m_fakeBlinkCaretTimer.start();
        }

        public function undo():void {
            if (m_fakeBlinkCaretTimer.running) {
                manageCurrentTypedText();
            }
            if (m_currentIndex != 0) {
                m_currentIndex--;
                var difference:Difference = Difference(m_differences.getItemAt(m_currentIndex));
                var currentCaretPosition:int = 0;
                for each (var operation:Operation in difference.operations) {
                    switch (operation.type) {
                        case Operation.EQUAL:
                            currentCaretPosition += operation.content.length;
                            break;
                        case Operation.INSERT:
                            currentCaretPosition = undoInsert(operation.content, currentCaretPosition);
                            break;
                        case Operation.DELETE:
                            currentCaretPosition = undoDelete(operation.content, currentCaretPosition);
                            break;
                    }
                }
            }
        }

        public function redo():void {
            if (m_currentIndex < m_differences.length && !m_fakeBlinkCaretTimer.running) {
                var difference:Difference = Difference(m_differences.getItemAt(m_currentIndex));
                var currentCaretPosition:int = 0;
                for each (var operation:Operation in difference.operations) {
                    switch (operation.type) {
                        case Operation.EQUAL:
                            currentCaretPosition += operation.content.length;
                            break;
                        case Operation.INSERT:
                            currentCaretPosition = redoInsert(operation.content, currentCaretPosition);
                            break;
                        case Operation.DELETE:
                            currentCaretPosition = redoDelete(operation.content, currentCaretPosition);
                            break;
                    }
                }
                m_currentIndex++;
            }
        }

        private function undoDelete(content:String, currentCaretPosition:int):int {
            debug("undoDelete", currentCaretPosition, content);
            modifyTextAreaContent(content, currentCaretPosition, currentCaretPosition, currentCaretPosition + content.length);
            currentCaretPosition += content.length;
            return currentCaretPosition;
        }

        private function undoInsert(content:String, currentCaretPosition:int):int {
            debug("undoInsert", currentCaretPosition, content);
            modifyTextAreaContent("", currentCaretPosition, currentCaretPosition + content.length, currentCaretPosition);
            return currentCaretPosition;
        }

        private function redoDelete(content:String, currentCaretPosition:int):int {
            debug("redoDelete", currentCaretPosition, content);
            modifyTextAreaContent("", currentCaretPosition, currentCaretPosition + content.length, currentCaretPosition);
            return currentCaretPosition;
        }

        private function redoInsert(content:String, currentCaretPosition:int):int {
            debug("redoInsert", currentCaretPosition, content);
            modifyTextAreaContent(content, currentCaretPosition, currentCaretPosition, currentCaretPosition + content.length);
            currentCaretPosition += content.length;
            return currentCaretPosition;
        }

        private function modifyTextAreaContent(content:String, beginIndex:int, endIndex:int, caretPosition:int):void {
            new TextRange(m_textArea, false, beginIndex, endIndex).text = content;
            m_previousText = m_textField.text;
            m_textArea.callLater(setSelectionAndFocus, [caretPosition]);
        }

        private function setSelectionAndFocus(focusPosition:int):void {
            m_textArea.selectionBeginIndex = focusPosition;
            m_textArea.selectionEndIndex = focusPosition;
            m_textArea.setFocus();
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

        public function get commands():ArrayCollection {
            return m_differences;
        }

        //region Debug

        /**
         * ex: debug("redoInsert", currentCaretPosition, content);
         */
        private static function debug(functionName:String, currentCaretPosition:int, content:String):void {
            trace(functionName + " content " + " at currentCaretPosition:" + currentCaretPosition);
            debugTraceString(content);
        }

        public static function debugTraceString(content:String):void {
            var lines:Array = content.split("\r");
            trace("     ");
            for each (var line:String in lines) {
                trace("      " + line);
            }
        }

        //endregion
    }
}
