class Task {
  String title;
  String status;
  String owner;
  String description;
  var startDate;

  Task({this.title, this.status, this.owner, this.description, this.startDate});

  Task.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    status = json['status'];
    owner = json['owner'];
    description = json['description'];
    startDate = json['startDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['status'] = this.status;
    data['owner'] = this.owner;
    data['description'] = this.description;
    data['startDate'] = this.startDate;

    return data;
  }
}
