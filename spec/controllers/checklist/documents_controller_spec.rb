require 'spec_helper'

describe Checklist::DocumentsController do
  describe 'GET volume_download' do
    let(:s3_client) { instance_double(Aws::S3::Client) }
    let(:s3_presigner) { instance_double(Aws::S3::Presigner) }
    let(:bucket_name) { 'species-plus-test' }
    let(:signed_url) { 'https://example.com/prebuilt.zip' }

    before do
      allow(controller).to receive(:s3_client).and_return(s3_client)
      allow(controller).to receive(:s3_presigner).and_return(s3_presigner)
      allow(controller).to receive(:s3_bucket_name).and_return(bucket_name)
    end

    it 'redirects to the prebuilt S3 zip for explicit volumes' do
      expected_filename = 'Identifications-documents-volume-1,3.zip'
      expected_key = "ID_manual_volumes/prebuilt_zip/en/#{expected_filename}"

      expect(s3_client).to receive(:head_object).with(
        bucket: bucket_name,
        key: expected_key
      )
      expect(s3_presigner).to receive(:presigned_url).with(
        :get_object,
        bucket: bucket_name,
        key: expected_key,
        expires_in: 1.minute.to_i,
        response_content_disposition: %(attachment; filename="#{expected_filename}")
      ).and_return(signed_url)

      get :volume_download, params: { locale: 'en', volume: [ '3', '1', '3' ] }

      expect(response).to redirect_to(signed_url)
    end

    it 'falls back to all supported volumes when none are provided' do
      expected_filename = 'Identifications-documents-volume-1,2,3,4,5,6.zip'
      expected_key = "ID_manual_volumes/prebuilt_zip/fr/#{expected_filename}"

      expect(s3_client).to receive(:head_object).with(
        bucket: bucket_name,
        key: expected_key
      )
      expect(s3_presigner).to receive(:presigned_url).with(
        :get_object,
        bucket: bucket_name,
        key: expected_key,
        expires_in: 1.minute.to_i,
        response_content_disposition: %(attachment; filename="#{expected_filename}")
      ).and_return(signed_url)

      get :volume_download, params: { locale: 'fr' }

      expect(response).to redirect_to(signed_url)
    end

    it 'returns 404 for unsupported locales' do
      get :volume_download, params: { locale: 'de', volume: [ '1' ] }

      expect(response).to have_http_status(404)
    end

    it 'returns 404 for unsupported volumes' do
      get :volume_download, params: { locale: 'en', volume: [ '7' ] }

      expect(response).to have_http_status(404)
    end

    it 'returns 404 when the prebuilt object is missing' do
      allow(s3_client).to receive(:head_object).and_raise(
        Aws::S3::Errors::NotFound.new(nil, 'missing')
      )

      get :volume_download, params: { locale: 'es', volume: [ '2' ] }

      expect(response).to have_http_status(404)
    end
  end
end
