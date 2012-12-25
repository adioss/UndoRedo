package {
    public class StringDifferenceTest {
        public function StringDifferenceTest() {
        }

        [Test]
        public function testLevenshteinDistance():void {

        }

        [Test]
        public function testDifference():void {
            var s:String = StringDifferenceUtils.difference("test1", "test2");
            trace(s);
        }

        [Test]
        public function testIndexOfDifference():void {
            var s:int = StringDifferenceUtils.indexOfDifference("test1", "test2");
            trace(s);
        }
    }
}
