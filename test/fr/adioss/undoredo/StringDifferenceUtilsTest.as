package fr.adioss.undoredo {
    import fr.adioss.undoredo.model.ComplexDifference;
    import fr.adioss.undoredo.model.Difference;

    import org.flexunit.Assert;

    public class StringDifferenceUtilsTest {

        [Test]
        public function shouldFindSimpleAddition():void {
            var original:String = "";
            var modified:String = "test";
            var difference:Difference = StringDifferenceUtils.difference(original, modified);
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.position, 0);
            Assert.assertEquals(difference.originalContentAfterPosition, "test");
            Assert.assertEquals(difference.type, Difference.ADDITION_DIFFERENCE_TYPE);
        }

        [Test]
        public function shouldFindSimpleSubtraction():void {
            var original:String = "test\r";
            var modified:String = "tes";
            var difference:Difference = StringDifferenceUtils.difference(original, modified);
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.position, 3);
            Assert.assertEquals(difference.originalContentAfterPosition, "t\r");
            Assert.assertEquals(difference.type, Difference.SUBTRACTION_DIFFERENCE_TYPE);
            original = "test\rtest\r";
            modified = "test\rte";
            difference = StringDifferenceUtils.difference(original, modified);
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.position, 7);
            Assert.assertEquals(difference.originalContentAfterPosition, "st\r");
            Assert.assertEquals(difference.type, Difference.SUBTRACTION_DIFFERENCE_TYPE);
            original = "test\rtest\r";
            modified = "test\rtet\r";
            difference = StringDifferenceUtils.difference(original, modified);
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.position, 7);
            Assert.assertEquals(difference.originalContentAfterPosition, "s");
            Assert.assertEquals(difference.type, Difference.SUBTRACTION_DIFFERENCE_TYPE);
        }

        [Test]
        public function shouldFindAddedText():void {
            var original:String = "line1\rline2\rline3";
            var modified:String = "line1\rline2\rmuchline3";
            var difference:Difference = StringDifferenceUtils.difference(original, modified);
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.position, 12);
            Assert.assertEquals(difference.originalContentAfterPosition, "much");
            Assert.assertEquals(difference.type, Difference.ADDITION_DIFFERENCE_TYPE);
        }

        [Test]
        public function shouldFindDeletedText():void {
            var original:String = "line1\rline2\rline3";
            var modified:String = "line1\rlineline3";
            var difference:Difference = StringDifferenceUtils.difference(original, modified);
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.position, 10);
            Assert.assertEquals(difference.originalContentAfterPosition, "2\r");
            Assert.assertEquals(difference.type, Difference.SUBTRACTION_DIFFERENCE_TYPE);
        }

        [Test]
        public function shouldFindComplexModification():void {
            var original:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + "\n"
                    + "<routes xmlns:u=\"http://www.systar.com/aluminium/camel-util\" xmlns=\"http://camel.apache.org/schema/spring\">" + "\n" + "</routes>";
            var modified:String = "<!--<?xml version=\"1.0\" encoding=\"UTF-8\"?>-->" + "\n"
                    + "<!--<routes xmlns:u=\"http://www.systar.com/aluminium/camel-util\" xmlns=\"http://camel.apache.org/schema/spring\">-->" + "\n"
                    + "<!--</routes>-->";
            var difference:ComplexDifference = ComplexDifference(StringDifferenceUtils.difference(original, modified));
            Assert.assertNotNull(difference);
            Assert.assertEquals(difference.type, Difference.COMPLEX_DIFFERENCE_TYPE);
            Assert.assertEquals(difference.position, 1);
            Assert.assertEquals(difference.originalContentAfterPosition, "?xml version=\"1.0\" encoding=\"UTF-8\"?>" + "\n"
                    + "<routes xmlns:u=\"http://www.systar.com/aluminium/camel-util\" xmlns=\"http://camel.apache.org/schema/spring\">" + "\n" + "</routes>");
            Assert.assertEquals(difference.modifiedContentAfterPosition, "!--<?xml version=\"1.0\" encoding=\"UTF-8\"?>-->" + "\n"
                    + "<!--<routes xmlns:u=\"http://www.systar.com/aluminium/camel-util\" xmlns=\"http://camel.apache.org/schema/spring\">-->" + "\n"
                    + "<!--</routes>-->");
        }
    }
}
