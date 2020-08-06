class Task {
  String title;
  String status;
  String owner;
  String description;
  var date;

  Task({this.title, this.status, this.owner, this.description, this.date});

  Task.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    status = json['status'];
    owner = json['owner'];
    description = json['description'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['status'] = this.status;
    data['owner'] = this.owner;
    data['description'] = this.description;
    data['date'] = this.date;

    return data;
  }
}
