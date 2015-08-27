// Model for Task Class
class Task {
  final int id;
  final String text;
  final bool checked;

  Task(this.text, this.checked, {this.id});

  Task.fromJson(Map value):
    id = value['_id'],
    text = value['text'],
    checked = value['checked'];

  String toString() => '${id}. ' + ( (checked) ? 'You\'ve done of ${text}' : 'You have to $text' );

  Map toRaw() {
    return {
      'text': this.text,
      'checked': this.checked
    };
  }
}