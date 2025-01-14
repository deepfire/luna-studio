// Generated by CoffeeScript 1.12.7
(function() {
  var lunaClasses;

  lunaClasses = {
    BlockStart: 'entity.lambda',
    Group: 'entity.group',
    Ident: 'variable',
    Var: 'variable.regular',
    Cons: 'variable.constructor',
    Wildcard: 'variable.wildcard',
    Keyword: 'keyword',
    KwCase: 'keyword.control.case',
    KwOf: 'keyword.control.of',
    KwClass: 'keyword.definition.class',
    KwDef: 'keyword.definition.function',
    KwImport: 'keyword.definition.import',
    Operator: 'keyword.operator',
    Modifier: 'keyword.operator.modifier',
    Accessor: 'keyword.operator.accessor',
    Assignment: 'keyword.operator.assignment',
    Range: 'keyword.operator.range',
    Anything: 'keyword.operator.anything',
    Literal: 'constant',
    Number: 'constant.numeric',
    List: 'constant.list',
    Str: 'string',
    Block: 'string.escape',
    Quote: 'string.quote',
    StrEsc: 'constant.character.escape',
    Unknown: 'invalid.unknown',
    StrWrongEsc: 'invalid.constant.character.escape',
    Comment: 'comment',
    Disable: 'comment.disabled',
    Doc: 'comment.doc',
    Marker: 'helper.marker'
  };

  module.exports = {
    lunaClass: function(tag) {
      return lunaClasses[tag];
    }
  };

}).call(this);
