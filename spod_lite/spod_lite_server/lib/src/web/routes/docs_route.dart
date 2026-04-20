import 'dart:io';

import 'package:markdown/markdown.dart' as md;
import 'package:serverpod/serverpod.dart';

/// Metadata for every doc we render. Keeping this in code (not on disk)
/// lets us control title/summary/order without parsing YAML front-matter.
class _Doc {
  final String slug;
  final String title;
  final String summary;
  final String icon; // inline SVG path d= value
  const _Doc(this.slug, this.title, this.summary, this.icon);
}

const _iconRocket =
    'M13 10V3L4 14h7v7l9-11h-7z';
const _iconArchitecture =
    'M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4';
const _iconBook =
    'M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253';
const _iconShield =
    'M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z';
const _iconSignal =
    'M5.636 18.364a9 9 0 010-12.728m12.728 0a9 9 0 010 12.728m-9.9-2.829a5 5 0 010-7.07m7.072 0a5 5 0 010 7.07M13 12a1 1 0 11-2 0 1 1 0 012 0z';
const _iconFile =
    'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z';
const _iconFlag =
    'M3 21v-4m0 0V5a2 2 0 012-2h6.5l1 1H21l-3 6 3 6h-8.5l-1-1H5a2 2 0 00-2 2zm9-13.5V9';

const _docs = <_Doc>[
  _Doc('getting-started', 'Getting started',
      'Zero to first record in ~5 minutes.', _iconRocket),
  _Doc('architecture', 'Architecture',
      'How the server, client, SDK, and dashboard fit together.',
      _iconArchitecture),
  _Doc('sdk', 'SDK reference',
      'Every method on spod.auth, spod.userAuth, spod.collections.',
      _iconBook),
  _Doc('rules', 'Rules',
      'Per-op access rules — public / authed / admin.', _iconShield),
  _Doc('realtime', 'Realtime',
      'watch() streams over WebSocket.', _iconSignal),
  _Doc('files', 'File uploads',
      'Upload, storage, serving.', _iconFile),
  _Doc('proposal', 'Proposal (RFC)',
      'The pitch for Serverpod upstream.', _iconFlag),
];

/// Serves `/docs` (index) and `/docs/<slug>` (rendered markdown).
class DocsRoute extends Route {
  @override
  Future<Response> handleCall(Session session, Request request) async {
    final segments = request.url.pathSegments;

    // `/docs` or `/docs/`
    if (segments.length <= 1) return _html(_renderIndex());

    final slug = segments[1];
    final doc = _findDoc(slug);
    if (doc == null) {
      return _html(_renderNotFound(slug), status: 404);
    }

    final file = _resolveMarkdownFile(slug);
    if (file == null) {
      return _html(_renderMissingSource(doc), status: 404);
    }

    final source = await file.readAsString();
    final html = _renderMarkdown(source);
    return _html(_renderPage(doc, html));
  }

  Response _html(String html, {int status = 200}) {
    final body = Body.fromString(html, mimeType: MimeType.html);
    switch (status) {
      case 404:
        return Response.notFound(body: body);
      default:
        return Response.ok(body: body);
    }
  }

  _Doc? _findDoc(String slug) {
    for (final d in _docs) {
      if (d.slug == slug) return d;
    }
    return null;
  }

  /// Tries the dev monorepo layout first, then `web/docs/` (for when docs
  /// have been copied into the server bundle for prod).
  File? _resolveMarkdownFile(String slug) {
    for (final candidate in [
      '../../docs/$slug.md',
      'web/docs/$slug.md',
    ]) {
      final f = File(candidate);
      if (f.existsSync()) return f;
    }
    return null;
  }

  String _renderMarkdown(String source) {
    final html = md.markdownToHtml(
      source,
      extensionSet: md.ExtensionSet.gitHubWeb,
      inlineSyntaxes: [md.InlineHtmlSyntax()],
    );
    // Rewrite inter-doc links: `[title](sdk.md)` → `/docs/sdk`.
    return html.replaceAllMapped(
      RegExp(r'href="([a-z0-9_-]+)\.md"'),
      (m) => 'href="/docs/${m.group(1)}"',
    );
  }

  String _renderIndex() {
    final cards = _docs.map((d) => _indexCard(d)).join('\n');
    return _pageWrap(
      title: 'Docs · Serverpod Lite',
      heading: 'Documentation',
      subtitle:
          'Everything you need to run Serverpod Lite, build against it, or ship it.',
      body: '<section class="grid grid-cols-1 md:grid-cols-2 gap-4">\n$cards\n</section>',
      activeSlug: null,
    );
  }

  String _renderPage(_Doc doc, String body) {
    return _pageWrap(
      title: '${doc.title} · Serverpod Lite docs',
      heading: doc.title,
      subtitle: doc.summary,
      body:
          '<article class="prose prose-invert max-w-none">\n$body\n</article>',
      activeSlug: doc.slug,
    );
  }

  String _renderNotFound(String slug) => _pageWrap(
        title: 'Not found · Serverpod Lite docs',
        heading: 'No such doc',
        subtitle:
            'The path <code class="font-mono text-sky-400">/docs/$slug</code> isn\'t one of our guides.',
        body:
            '<p class="text-slate-400 text-[14px]">Go back to <a href="/docs" class="text-sky-400 hover:underline">the docs index</a>.</p>',
        activeSlug: null,
      );

  String _renderMissingSource(_Doc doc) => _pageWrap(
        title: '${doc.title} · Serverpod Lite docs',
        heading: doc.title,
        subtitle:
            'Source file is missing from this build. Copy the repo\'s <code class="font-mono text-sky-400">docs/</code> directory into <code class="font-mono text-sky-400">spod_lite_server/web/docs/</code>.',
        body: '',
        activeSlug: doc.slug,
      );

  String _indexCard(_Doc d) => '''
<a href="/docs/${d.slug}" class="group glass rounded-2xl p-6 hover:border-sky-500/40 transition-all hover:-translate-y-0.5">
  <div class="flex items-start justify-between mb-3">
    <div class="w-10 h-10 rounded-xl bg-sky-500/10 border border-sky-500/30 flex items-center justify-center">
      <svg class="w-5 h-5 text-sky-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="${d.icon}"/></svg>
    </div>
    <svg class="w-5 h-5 text-slate-600 group-hover:text-sky-400 group-hover:translate-x-0.5 transition-all" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg>
  </div>
  <div class="text-[15px] font-semibold mb-1">${d.title}</div>
  <p class="text-[13px] text-slate-400">${d.summary}</p>
</a>''';

  String _sidebarList(String? activeSlug) {
    return _docs
        .map((d) {
          final active = d.slug == activeSlug;
          final classes = active
              ? 'bg-sky-500/10 border-sky-500/30 text-slate-100'
              : 'border-transparent hover:bg-ink-800/60 hover:border-ink-600 text-slate-400 hover:text-slate-200';
          return '<a href="/docs/${d.slug}" class="block px-3 py-2 rounded-lg border $classes text-[13px] transition-colors">${d.title}</a>';
        })
        .join('\n');
  }

  String _pageWrap({
    required String title,
    required String heading,
    required String subtitle,
    required String body,
    required String? activeSlug,
  }) {
    final sidebar = _sidebarList(activeSlug);
    final wrap = activeSlug == null
        ? '''
<section class="mb-12">
  <h1 class="text-4xl md:text-5xl font-bold tracking-tighter mb-3">$heading</h1>
  <p class="text-slate-400 text-[15px] max-w-2xl">$subtitle</p>
</section>
$body
'''
        : '''
<div class="grid grid-cols-1 md:grid-cols-[220px_1fr] gap-8 md:gap-12">
  <aside class="md:sticky md:top-6 self-start">
    <div class="text-[10px] font-semibold tracking-widest text-slate-500 uppercase mb-3">Docs</div>
    <nav class="flex flex-col gap-1">
      $sidebar
    </nav>
  </aside>
  <div>
    <section class="mb-10">
      <div class="text-[11px] font-semibold tracking-widest text-sky-400 uppercase mb-2">Documentation</div>
      <h1 class="text-3xl md:text-4xl font-bold tracking-tight mb-3">$heading</h1>
      <p class="text-slate-400 text-[14.5px] max-w-2xl">$subtitle</p>
    </section>
    $body
  </div>
</div>
''';

    return '''
<!DOCTYPE html>
<html lang="en" class="dark">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>$title</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          fontFamily: {
            sans: ['Inter','ui-sans-serif','system-ui'],
            mono: ['JetBrains Mono','ui-monospace','monospace'],
          },
          colors: {
            ink: {
              950: '#05070A', 900: '#0B0F14', 850: '#0F141B',
              800: '#141A22', 700: '#1C242F', 600: '#232C38',
              500: '#343F4C',
            }
          }
        }
      }
    }
  </script>
  <style type="text/tailwindcss">
    @layer base {
      html, body { @apply bg-ink-950 text-slate-100 font-sans antialiased; }
    }
    @layer components {
      .glass {
        @apply bg-ink-850/60 border border-ink-600/60;
      }
    }
    @layer utilities {
      .prose-invert h1, .prose-invert h2, .prose-invert h3, .prose-invert h4 {
        @apply text-slate-100 font-semibold tracking-tight;
      }
      .prose-invert h1 { @apply text-[28px] mt-12 mb-5; }
      .prose-invert h2 { @apply text-[22px] mt-10 mb-4 pb-2 border-b border-ink-600/40; }
      .prose-invert h3 { @apply text-[17px] mt-8 mb-3; }
      .prose-invert p  { @apply text-slate-300 text-[14.5px] leading-[1.7] mb-5; }
      .prose-invert ul, .prose-invert ol { @apply text-slate-300 text-[14.5px] leading-[1.7] mb-5 pl-6; }
      .prose-invert ul { @apply list-disc; }
      .prose-invert ol { @apply list-decimal; }
      .prose-invert li { @apply mb-1.5; }
      .prose-invert a  { @apply text-sky-400 hover:underline; }
      .prose-invert strong { @apply text-slate-100; }
      .prose-invert code {
        @apply font-mono text-[12.5px] bg-ink-800/80 border border-ink-600/50 text-sky-300 rounded px-1.5 py-[1px];
      }
      .prose-invert pre {
        @apply bg-ink-900 border border-ink-600/60 rounded-xl p-5 overflow-x-auto text-[13px] leading-[1.7] mb-6;
      }
      .prose-invert pre code {
        @apply bg-transparent border-0 text-slate-200 p-0;
      }
      .prose-invert table {
        @apply w-full text-[13.5px] mb-6 border border-ink-600/60 rounded-lg overflow-hidden;
      }
      .prose-invert thead { @apply bg-ink-800/60; }
      .prose-invert th    { @apply text-left px-3 py-2 border-b border-ink-600/60 text-slate-200 font-semibold text-[12.5px] uppercase tracking-wide; }
      .prose-invert td    { @apply px-3 py-2 border-t border-ink-600/30 text-slate-300; }
      .prose-invert blockquote {
        @apply border-l-4 border-sky-500/40 pl-4 italic text-slate-400 my-5;
      }
      .prose-invert hr {
        @apply border-ink-600/50 my-10;
      }
    }
  </style>
</head>
<body>
  <div class="max-w-6xl mx-auto px-6 pt-8 pb-24">
    <nav class="flex items-center justify-between mb-10">
      <a href="/" class="flex items-center gap-3 group">
        <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-sky-400 to-sky-600 flex items-center justify-center text-black font-extrabold text-lg shadow-lg shadow-sky-500/30 -tracking-wider">S</div>
        <div class="flex flex-col leading-tight">
          <span class="text-[15px] font-semibold tracking-tight">Serverpod Lite</span>
          <span class="text-[11px] text-slate-500">Docs</span>
        </div>
      </a>
      <div class="flex items-center gap-4 text-[12px] text-slate-400">
        <a href="/" class="hover:text-sky-400">Home</a>
        <a href="/app/" class="hover:text-sky-400">Dashboard</a>
        <a href="https://github.com/MartinPirate/spod_lite" class="hover:text-sky-400" target="_blank" rel="noopener">GitHub</a>
      </div>
    </nav>
    $wrap
    <footer class="pt-12 mt-16 border-t border-ink-600/40 text-[12px] text-slate-500">
      <a href="/" class="hover:text-sky-400">← Back to landing</a>
    </footer>
  </div>
</body>
</html>
''';
  }
}
