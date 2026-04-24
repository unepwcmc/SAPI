Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    app_cors_origins =
      Rails.application.credentials.dig(
        :cors, :origins
      ) || []

    origins app_cors_origins&.map(&:strip)

    resource '*', headers: :any, methods: [
      :get, :post, :patch, :put, :delete
    ]
  end
end
