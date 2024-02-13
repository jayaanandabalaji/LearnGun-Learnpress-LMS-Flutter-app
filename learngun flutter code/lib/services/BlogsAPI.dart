import 'BaseAPI.dart';
import '../../Models/Blogs.dart';

class BlogsApi {
  GetBlogs({int page = 1}) async {
    var response = await baseAPI().getAsync("wp/v2/posts?_embed&per_page=10&page=${page}", customUrl: true);
    return response.map((value) => blogs.fromJson(value)).toList();
  }

  GetWebinars({int page = 1}) async {
    var response = await baseAPI().getAsync("wp/v2/zoom_meetings?_embed&per_page=10&page=${page}", customUrl: true);
    return response.map((value) => blogs.fromJson(value)).toList();
  }

  GetMeeting(String postId) async {
    var response = await baseAPI().getAsync("wp/v2/zoom_meetings/${postId}?_embed", customUrl: true);
    return blogs.fromJson(response);
  }

  GetOtherResources({int page = 1}) async {
    var response = await baseAPI().getAsync("wp/v2/app-resources?_embed&per_page=10&page=${page}", customUrl: true);
    return response.map((value) => blogs.fromJson(value)).toList();
  }
}
