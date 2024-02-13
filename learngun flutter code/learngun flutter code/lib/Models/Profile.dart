import 'package:json_annotation/json_annotation.dart';
part 'Profile.g.dart';

@JsonSerializable()
class Profile {
  num id;
  String username;
  String name;
  String first_name;
  String last_name;
  String email;
  String description;
  String link;
  String avatar_url;
  Socialbean social;
  tabsbean tabs;
  Profile(
      {required this.id,
      required this.username,
      required this.name,
      required this.first_name,
      required this.last_name,
      required this.email,
      required this.description,
      required this.link,
      required this.avatar_url,
      required this.social,
      required this.tabs});
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class Socialbean {
  String facebook;
  String twitter;
  String youtube;
  String linkedin;
  Socialbean({required this.facebook, required this.twitter, required this.youtube, required this.linkedin});
  factory Socialbean.fromJson(Map<String, dynamic> json) => _$SocialbeanFromJson(json);
  Map<String, dynamic> toJson() => _$SocialbeanToJson(this);
}

@JsonSerializable()
class tabsbean {
  Ordersbean orders;
  tabsbean({required this.orders});
  factory tabsbean.fromJson(Map<String, dynamic> json) => _$tabsbeanFromJson(json);
  Map<String, dynamic> toJson() => _$tabsbeanToJson(this);
}

@JsonSerializable()
class Ordersbean {
  var content;
  Ordersbean({required this.content});
  factory Ordersbean.fromJson(Map<String, dynamic> json) => _$OrdersbeanFromJson(json);
  Map<String, dynamic> toJson() => _$OrdersbeanToJson(this);
}
