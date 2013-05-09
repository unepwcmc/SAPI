Trade.UploadFileView = Ember.TextField.extend
    type: 'file'
    attributeBindings: ['name']
    change: (evt) ->
      self = @
      input = evt.target
      if (input.files && input.files[0])
        reader = new FileReader()
        reader.onload = (e) ->
          fileToUpload = e.srcElement.result
          self.get('controller').set(self.get('name'), fileToUpload)
        reader.readAsDataURL(input.files[0])
