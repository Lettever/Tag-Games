sealed class AstNode {
    @override
    String toString() => 'AstNode';
}

class Assignment extends AstNode {
    final Name name;
    final Value value;
    Assignment(this.name, this.value);

    @override
    String toString() => 'Assignment(name: $name, value: $value)';
}


sealed class Value extends AstNode {
    @override
    String toString() => 'Value';
}

class Block extends Value {
    final List<Value> values;
    Block(this.values);

    @override
    String toString() => 'Block(values: $values)';
}

class TypedBlock extends Value {
    final Name name;
    final Block block;
    TypedBlock(this.name, this.block);

    @override
    String toString() => 'TypedBlock(name: $name, block: $block)';
}

class MemberAccess extends Value {
    final Name root;
    final List<Name> members;
    MemberAccess(this.root, this.members);

    @override
    String toString() => 'MemberAccess(root: $root, members: $members)';
}

class Name extends Value {
    final String name;
    Name(this.name);

    @override
    String toString() => 'name: ${name}';
}

