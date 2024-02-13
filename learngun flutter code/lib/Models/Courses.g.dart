// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Courses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Courses _$CoursesFromJson(Map<String, dynamic> json) => Courses(
      id: json['id'] as num,
      membership: json['membership'],
      name: json['name'] as String,
      permalink: json['permalink'] as String,
      image: json['image'] as String,
      on_sale: json['on_sale'] as bool,
      status: json['status'] as String,
      date_modified_gmt: json['date_modified_gmt'] as String,
      content: json['content'] as String,
      duration: json['duration'] as String,
      can_retake: json['can_retake'],
      ratake_count: json['ratake_count'] as int,
      can_finish: json['can_finish'] as bool,
      rating: json['rating'],
      count_students: json['count_students'] as num,
      price: json['price'] as num,
      origin_price: json['origin_price'] as num,
      sale_price: json['sale_price'] as num,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => CategoryBean.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => TagsBean.fromJson(e as Map<String, dynamic>))
          .toList(),
      instructor:
          InstructorBean.fromJson(json['instructor'] as Map<String, dynamic>),
      sections: (json['sections'] as List<dynamic>)
          .map((e) => SectionBean.fromJson(e as Map<String, dynamic>))
          .toList(),
      course_data:
          CourseDataBean.fromJson(json['course_data'] as Map<String, dynamic>),
      meta_data:
          metaDataBean.fromJson(json['meta_data'] as Map<String, dynamic>),
      certificate: json['certificate'],
    );

Map<String, dynamic> _$CoursesToJson(Courses instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'permalink': instance.permalink,
      'image': instance.image,
      'on_sale': instance.on_sale,
      'status': instance.status,
      'date_modified_gmt': instance.date_modified_gmt,
      'content': instance.content,
      'duration': instance.duration,
      'can_retake': instance.can_retake,
      'ratake_count': instance.ratake_count,
      'can_finish': instance.can_finish,
      'rating': instance.rating,
      'count_students': instance.count_students,
      'price': instance.price,
      'origin_price': instance.origin_price,
      'sale_price': instance.sale_price,
      'categories': instance.categories,
      'tags': instance.tags,
      'instructor': instance.instructor,
      'sections': instance.sections,
      'course_data': instance.course_data,
      'meta_data': instance.meta_data,
      'certificate': instance.certificate,
      'membership': instance.membership,
    };

CategoryBean _$CategoryBeanFromJson(Map<String, dynamic> json) => CategoryBean(
      id: json['id'] as num? ?? -1,
      name: json['name'] as String? ?? "",
      slug: json['slug'] as String? ?? "",
    );

Map<String, dynamic> _$CategoryBeanToJson(CategoryBean instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };

TagsBean _$TagsBeanFromJson(Map<String, dynamic> json) => TagsBean(
      id: json['id'] as num? ?? -1,
      name: json['name'] as String? ?? "",
      slug: json['slug'] as String? ?? "",
    );

Map<String, dynamic> _$TagsBeanToJson(TagsBean instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };

InstructorBean _$InstructorBeanFromJson(Map<String, dynamic> json) =>
    InstructorBean(
      avatar: json['avatar'] as String? ?? "",
      id: json['id'] as num? ?? -1,
      name: json['name'] as String? ?? "",
      description: json['description'] as String? ?? "",
    );

Map<String, dynamic> _$InstructorBeanToJson(InstructorBean instance) =>
    <String, dynamic>{
      'avatar': instance.avatar,
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };

CourseDataBean _$CourseDataBeanFromJson(Map<String, dynamic> json) =>
    CourseDataBean(
      graduation: json['graduation'] as String,
      start_time: json['start_time'] as String? ?? "",
      end_time: json['end_time'] ?? "",
      status: json['status'] as String,
      result:
          courseResultsBean.fromJson(json['result'] as Map<String, dynamic>),
      expiration_time: json['expiration_time'] as String,
    );

Map<String, dynamic> _$CourseDataBeanToJson(CourseDataBean instance) =>
    <String, dynamic>{
      'graduation': instance.graduation,
      'status': instance.status,
      'start_time': instance.start_time,
      'end_time': instance.end_time,
      'expiration_time': instance.expiration_time,
      'result': instance.result,
    };

courseResultsBean _$courseResultsBeanFromJson(Map<String, dynamic> json) =>
    courseResultsBean(
      result: json['result'] as num,
      completed_items: json['completed_items'] as num,
      count_items: json['count_items'] as num,
    );

Map<String, dynamic> _$courseResultsBeanToJson(courseResultsBean instance) =>
    <String, dynamic>{
      'result': instance.result,
      'count_items': instance.count_items,
      'completed_items': instance.completed_items,
    };

SectionBean _$SectionBeanFromJson(Map<String, dynamic> json) => SectionBean(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      percent: json['percent'] as num? ?? 0,
      items: (json['items'] as List<dynamic>)
          .map((e) => ItemsBean.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SectionBeanToJson(SectionBean instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'percent': instance.percent,
      'items': instance.items,
    };

ItemsBean _$ItemsBeanFromJson(Map<String, dynamic> json) => ItemsBean(
      id: json['id'] as num,
      title: json['title'] as String,
      type: json['type'] as String,
      preview: json['preview'] as bool,
      duration: json['duration'] as String,
      graduation: json['graduation'] as String,
      status: json['status'] as String,
      locked: json['locked'] as bool,
    );

Map<String, dynamic> _$ItemsBeanToJson(ItemsBean instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'preview': instance.preview,
      'duration': instance.duration,
      'graduation': instance.graduation,
      'status': instance.status,
      'locked': instance.locked,
    };

metaDataBean _$metaDataBeanFromJson(Map<String, dynamic> json) => metaDataBean(
      lp_level: json['_lp_level'],
      lp_requirements: json['_lp_requirements'],
      lp_target_audiences: json['_lp_target_audiences'],
      lp_key_features: json['_lp_key_features'],
      lp_faqs: json['_lp_faqs'],
    );

Map<String, dynamic> _$metaDataBeanToJson(metaDataBean instance) =>
    <String, dynamic>{
      '_lp_level': instance.lp_level,
      '_lp_requirements': instance.lp_requirements,
      '_lp_target_audiences': instance.lp_target_audiences,
      '_lp_key_features': instance.lp_key_features,
      '_lp_faqs': instance.lp_faqs,
    };
