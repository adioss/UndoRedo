package fr.adioss.undoredo.model {
    import mx.collections.ArrayCollection;

    public class Difference {
        public var operations:ArrayCollection/*of Operation*/;

        public function Difference(operations:Array) {
            this.operations = new ArrayCollection(operations);
        }
    }
}
