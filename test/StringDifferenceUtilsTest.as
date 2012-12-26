package {
    import org.flexunit.Assert;

    public class StringDifferenceUtilsTest {

        [Test]
        public function shouldFindSimpleAddition():void {
            var original:String = "";
            var modified:String = "test";
            var difference:Difference = StringDifferenceUtils.difference(original, modified);
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.position, 0);
            Assert.assertEquals(difference.content, "test");
            Assert.assertEquals(difference.type, Difference.ADDITION_DIFFERENCE_TYPE);
        }

        [Test]
        public function shouldFindSimpleSubtraction():void {
            var original:String = "test\r";
            var modified:String = "tes";
            var difference:Difference = StringDifferenceUtils.difference(original, modified);
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.position, 3);
            Assert.assertEquals(difference.content, "t\r");
            Assert.assertEquals(difference.type, Difference.SUBTRACTION_DIFFERENCE_TYPE);
            original = "test\rtest\r";
            modified = "test\rte";
            difference = StringDifferenceUtils.difference(original, modified);
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.position, 7);
            Assert.assertEquals(difference.content, "st\r");
            Assert.assertEquals(difference.type, Difference.SUBTRACTION_DIFFERENCE_TYPE);
        }

        [Test]
        public function shouldFindAddedText():void {
            var original:String = "line1\rline2\rline3";
            var modified:String = "line1\rline2\rmuchline3";
            var difference:Difference = StringDifferenceUtils.difference(original, modified);
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.position, 12);
            Assert.assertEquals(difference.content, "much");
            Assert.assertEquals(difference.type, Difference.ADDITION_DIFFERENCE_TYPE);
        }

        [Test]
        public function shouldFindDeletedText():void {
            var original:String = "line1\rline2\rline3";
            var modified:String = "line1\rlineline3";
            var difference:Difference = StringDifferenceUtils.difference(original, modified);
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.position, 10);
            Assert.assertEquals(difference.content, "2\r");
            Assert.assertEquals(difference.type, Difference.SUBTRACTION_DIFFERENCE_TYPE);
        }
    }
}
