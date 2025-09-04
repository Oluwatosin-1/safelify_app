import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

class HtmlWidget extends StatelessWidget {
  final String? postContent;
  final Color? color;

  HtmlWidget({this.postContent, this.color});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: postContent,
      shrinkWrap: true,
      onAnchorTap: (url, attributes, element) {
        if (url.validate().isNotEmpty) {
          launchUrlCustomTab(url.validate());
        }
      },
      onLinkTap: (url, attributes, element) {
        if (url.validate().isNotEmpty) {
          launchUrlCustomTab(url.validate());
        }
      },
      style: {
        'embed': Style(color: color ?? transparentColor, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: FontSize(16)),
        'strong': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'a': Style(color: color ?? appPrimaryColor, fontWeight: FontWeight.w400, fontSize: FontSize(16),textAlign: TextAlign.justify,wordSpacing: 1),
        'div': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'figure': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16), margin: Margins(left: Margin.zero()),wordSpacing: 1),
        'h1': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'h2': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(14),wordSpacing: 1),
        'h3': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(12),wordSpacing: 1),
        'h4': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(10),wordSpacing: 1),
        'h5': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(8),wordSpacing: 1),
        'h6': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(8),wordSpacing: 1),
        'ol': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'ul': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'strike': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'u': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'b': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'i': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'hr': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'header': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'code': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'data': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'body': Style(
          color: color ?? textPrimaryColorGlobal,
          fontSize: FontSize(16),
          textAlign: TextAlign.justify,
          wordSpacing: 1,
          padding: HtmlPaddings.zero,
          alignment: Alignment.center,
          whiteSpace: WhiteSpace.normal
        ),
        'big': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'blockquote': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16),wordSpacing: 1),
        'img': Style(width: Width(context.width() - 48), height: Height(200), fontSize: FontSize(16), alignment: Alignment.center),
      },
    );
  }
}
