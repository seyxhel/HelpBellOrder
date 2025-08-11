class Signup extends App.ControllerFullPage
  events:
    'submit form': 'submit'
    'click .submit': 'submit'
    'click .js-submitResend': 'resend'
    'click .cancel': 'cancel'
  className: 'signup'

  constructor: ->
    super

    # go back if feature is not enabled
    if !@Config.get('user_create_account')
      @navigate '#'
      return

    # set title
    @title __('Sign up')
    @navupdate '#signup'

    @publicLinksSubscribeId = App.PublicLink.subscribe(=>
      @render()
    )

    @render()

  release: =>
    if @publicLinksSubscribeId
      App.PublicLink.unsubscribe(@publicLinksSubscribeId)

  render: ->
    public_links = App.PublicLink.search(
      filter:
        screen: ['signup']
      sortBy: 'prio'
    )

    @replaceWith App.view('signup')(
      public_links: public_links
    )

    @form = new App.ControllerForm(
      el:        @el.find('form')
      model:     App.User
      screen:    'signup'
      autofocus: true
    )

  cancel: ->
    @navigate '#login'

  submit: (e) =>
    e.preventDefault()
    @formDisable(e)
    @params = @formParam(e.target)

    # if no login is given, use emails as fallback
    if !@params.login && @params.email
      @params.login = @params.email

    # Custom required fields validation for signup
    requiredFields = [@params.firstname, @params.lastname, @params.email, @params.password]
    if requiredFields.some((field) -> !field or field.trim() is '')
      @form.showAlert(App.i18n.translateContent('Please fill in all required fields.'))
      @formEnable(e)
      return false

    # Password validation (same as change password)
    password = @params.password
    passwordConfirm = @params.password_confirm
    rules = [
      { regex: /[A-Z]/, msg: __('Password must contain at least one uppercase letter.') },
      { regex: /[a-z]/, msg: __('Password must contain at least one lowercase letter.') },
      { regex: /[0-9]/, msg: __('Password must contain at least one number.') },
      { regex: /[^A-Za-z0-9]/, msg: __('Password must contain at least one special character.') },
      { regex: /.{8,}/, msg: __('Password must be at least 8 characters long.') }
    ]

    for rule in rules
      unless rule.regex.test(password)
        @formEnable(e)
        @form.showAlert(rule.msg)
        return false

    if passwordConfirm isnt password
      @formEnable(e)
      @form.showAlert(__('Password does not match.'))
      return false

    @params.signup = true
    @params.role_ids = []
    @log 'notice', 'updateAttributes', @params
    user = new App.User
    user.load(@params)

    errors = user.validate(
      controllerForm: @form
    )

    if errors
      # Only highlight, but don't add message. Error text breaks layout.
      Object.keys(errors).forEach (key) ->
        errors[key] = null

      @formValidate(form: e.target, errors: errors)
      @formEnable(e)
      return false
    else
      @formValidate(form: e.target, errors: errors)

    # save user
    user.save(
      done: (r) =>
        public_links = App.PublicLink.search(
          filter:
            screen: ['signup']
          sortBy: 'prio'
        )
        @replaceWith(App.view('signup/verify')(
          email:        @params.email
          public_links: public_links
        ))
      fail: (settings, details) =>
        @formEnable(e)

        message = if _.isArray(details.notice)
                    App.i18n.translateContent(details.notice[0], details.notice[1])
                  else
                    details.error_human || details.error || __('User could not be created.')

        @form.showAlert(message)
    )

  resend: (e) =>
    e.preventDefault()
    @formDisable(e)
    @resendParams = @formParam(e.target)

    @ajax(
      id:          'email_verify_send'
      type:        'POST'
      url:         @apiPath + '/users/email_verify_send'
      data:        JSON.stringify(email: @resendParams.email)
      processData: true
      success: (data, status, xhr) =>
        @formEnable(e)

        # add notify
        @notify(
          type:      'success'
          msg:       App.i18n.translateContent('Email sent to "%s". Please verify your email account.', @params.email)
          removeAll: true
        )

      error: @error
    )

  error: (xhr, statusText, error) =>
    detailsRaw = xhr.responseText
    details = {}
    if !_.isEmpty(detailsRaw)
      details = JSON.parse(detailsRaw)

    @notify(
      type:      'error'
      msg:       details.error || __('Could not process your request')
      removeAll: true
    )
App.Config.set('signup', Signup, 'Routes')
