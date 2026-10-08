# Keeps non-production deployments out of search engine indexes.
#
# staging.speciesplus.net was indexed by Google because it serves the same
# public/robots.txt as production, and that file's `Allow:` lines name the
# exact paths that got indexed. `Disallow: /` does not override them — the
# most specific rule wins, so `Allow: /species` beats it.
#
# robots.txt is the wrong tool regardless. It governs crawling, not indexing:
# a disallowed URL can still be listed in results as a bare link, and blocking
# it guarantees Googlebot never sees a removal signal. `X-Robots-Tag: noindex`
# is that signal, and it only works while crawling stays allowed, so the
# robots.txt served below is deliberately permissive.
#
# The header has to cover static files too — public/robots.txt and the Ember
# build are served by ActionDispatch::Static — so this middleware is inserted
# in front of the whole stack rather than into the Rails router.
class StagingNoindex
  HEADER = 'X-Robots-Tag'.freeze
  DIRECTIVES = 'noindex, nofollow, noarchive, nosnippet'.freeze

  ROBOTS_TXT = <<~TXT.freeze
    # Staging. Crawling is allowed on purpose: every response carries
    # X-Robots-Tag: noindex, and Googlebot has to be able to fetch a URL to
    # see it. Disallowing here would strand already-indexed URLs in results.
    #
    # Production's robots.txt lives in public/robots.txt and is unaffected.
    User-agent: *
    Allow: /
  TXT

  def initialize(app)
    @app = app
  end

  def call(env)
    return robots_txt_response if robots_txt_request?(env)

    status, headers, body = @app.call(env)
    headers[HEADER] = DIRECTIVES
    [status, headers, body]
  end

  private

  def robots_txt_request?(env)
    env['PATH_INFO'] == '/robots.txt' &&
      %w[GET HEAD].include?(env['REQUEST_METHOD'])
  end

  # Served from here rather than from a staging copy of public/robots.txt so
  # that the file on disk stays the production one in every environment.
  def robots_txt_response
    [
      200,
      {
        'Content-Type' => 'text/plain',
        'Content-Length' => ROBOTS_TXT.bytesize.to_s,
        HEADER => DIRECTIVES
      },
      [ROBOTS_TXT]
    ]
  end
end
