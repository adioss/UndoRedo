package fr.adioss.undoredo {
    import flexunit.framework.Assert;

    import fr.adioss.undoredo.model.Operation;

    public class StringDifferenceUtilsTest {

        [Test]
        public function shouldFindSimpleAddition():void {
            var beforeText:String;
            var afterText:String;
            var differences:Array;
            var operation:Operation;

            beforeText = "test with addition";
            afterText = "test with simple addition";
            differences = StringDifferenceUtils.difference(beforeText, afterText);
            Assert.assertNotNull(differences);
            Assert.assertEquals(3, differences.length);
            operation = differences[1] as Operation;
            Assert.assertEquals(operation.content, "simple ");
            Assert.assertEquals(operation.type, Operation.INSERT);

            beforeText = "test with addition";
            afterText = "test with \r addition";
            differences = StringDifferenceUtils.difference(beforeText, afterText);
            Assert.assertNotNull(differences);
            Assert.assertEquals(3, differences.length);
            operation = differences[1] as Operation;
            Assert.assertEquals(operation.content, "\r ");
            Assert.assertEquals(operation.type, Operation.INSERT);
        }

        [Test]
        public function shouldFindSimpleDeletion():void {
            var beforeText:String;
            var afterText:String;
            var differences:Array;
            var operation:Operation;

            beforeText = "test with  simple deletion";
            afterText = "test with deletion";
            differences = StringDifferenceUtils.difference(beforeText, afterText);
            Assert.assertNotNull(differences);
            Assert.assertEquals(3, differences.length);
            operation = differences[1] as Operation;
            Assert.assertEquals(operation.content, " simple ");
            Assert.assertEquals(operation.type, Operation.DELETE);

            beforeText = "test with \r deletion";
            afterText = "test with deletion";
            differences = StringDifferenceUtils.difference(beforeText, afterText);
            Assert.assertNotNull(differences);
            Assert.assertEquals(3, differences.length);
            operation = differences[1] as Operation;
            Assert.assertEquals(operation.content, "\r ");
            Assert.assertEquals(operation.type, Operation.DELETE);
        }

        [Test]
        public function shouldFindMultipleAddition():void {
            var beforeText:String;
            var afterText:String;
            var differences:Array;
            var operation:Operation;

            beforeText = "test with addition";
            afterText = "Another test, the second, with complex addition";
            differences = StringDifferenceUtils.difference(beforeText, afterText);
            Assert.assertNotNull(differences);
            Assert.assertEquals(6, differences.length);

            operation = differences[0] as Operation;
            Assert.assertEquals(operation.content, "Another ");
            Assert.assertEquals(operation.type, Operation.INSERT);

            operation = differences[2] as Operation;
            Assert.assertEquals(operation.content, ", the second,");
            Assert.assertEquals(operation.type, Operation.INSERT);

            operation = differences[4] as Operation;
            Assert.assertEquals(operation.content, " complex");
            Assert.assertEquals(operation.type, Operation.INSERT);
        }

        [Test]
        public function shouldFindMultipleAdditionAndDeletion():void {
            var beforeText:String;
            var afterText:String;
            var differences:Array;
            var operation:Operation;

            beforeText = "test with deletion/addition";
            afterText = "Another test with complex";
            differences = StringDifferenceUtils.difference(beforeText, afterText);
            Assert.assertNotNull(differences);
            Assert.assertEquals(7, differences.length);

            operation = differences[0] as Operation;
            Assert.assertEquals(operation.content, "Another ");
            Assert.assertEquals(operation.type, Operation.INSERT);

            operation = differences[2] as Operation;
            Assert.assertEquals(operation.content, "de");
            Assert.assertEquals(operation.type, Operation.DELETE);

            operation = differences[3] as Operation;
            Assert.assertEquals(operation.content, "comp");
            Assert.assertEquals(operation.type, Operation.INSERT);

            operation = differences[5] as Operation;
            Assert.assertEquals(operation.content, "tion/addition");
            Assert.assertEquals(operation.type, Operation.DELETE);

            operation = differences[6] as Operation;
            Assert.assertEquals(operation.content, "x");
            Assert.assertEquals(operation.type, Operation.INSERT);
        }
    }
}
