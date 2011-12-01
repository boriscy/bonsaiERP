# Backbone model
class ExchangeRate extends Backbone.Model
  defaults:
    rate: 1

  setAll: (input, observe, @currency_id, @accounts, @currencies, @options)->
    @.getRates()
    @inverse = false
    @$input  = $(input)
    @observe = observe
    @$label  = @$input.siblings 'label'
    @inverted = @options["inverted"] || false

    @$currencies = @$label.find(".currencies")
    @$hide   = if @options["hide"] then $(@options["hide"]) else @$input.parents "div:first"

    # Set rate if exists
    if @$input.val().match(/^\d+$/) or $(@observe).val().match(/^\d+$/)
      rate = @$input.val() * 1
      curr = $(@observe).val() * 1
      # Set the currency
      @.set({rate: rate, "currency": @currencies[curr]})
      @.setSuggestRates()
      @.triggerExchange()
      @.presentCurrency()
    else
      @$input.val(@.get("rate"))

    @.set( suggest_rate: @.get("rate").round(4) )
    # Events
    @.setEvents()
  # Events
  setEvents: ->
    self = @
    # Currency
    @.bind "change:currency", ->
      @.setCurrencyLabel()

    @.chageCurrencyEvent()
    @.rateEvents()
  # trigger for rate and currency
  triggerExchange: ->
    @.setSuggestRates()
    rate = @.get("rate")
    @$input.trigger("change:rate", [{rate: rate, currency: @.get("currency"), inverse: @inverse }])
  # Account event
  chageCurrencyEvent: ->
    self = @

    # Triggers the suggested:rate Event
    $(@observe)
    .off('change keyup')
    .on 'change keyup', ->
      html = ''
      rate = 0.0
      currency_id = false

      switch
        when $(@).val().match /^\d+$/
          val = $(@).val() * 1
          self.set({currency: self.currencies[self.accounts[val].currency_id]})
          self.setSuggestRates()
          self.triggerExchange()
        else
          self.$hide.hide 'slow'
          rate = 1

      self.$input.trigger('suggested:rate', [rate])
  # set the rate
  setRate: ->
    @$input.val(@.get("rate")).mark()
  # Sets the data for currency
  setCurrencyLabel: ->
    from = @currencies[@currency_id].symbol
    to   = @.get("currency").symbol

    if @inverse
      tmp  = from
      from = to
      to   = tmp

    @$currencies.html("(#{from} a #{to})")

    @.presentCurrency()
  # Presents the hidden div
  presentCurrency: ->
    if @currency_id == @.get("currency").id
      @$hide.hide('slow')
     else
       @$hide.show('slow')
  # Set the rate for a currency
  setSuggestRates: ->
    try
      from = @currencies[@currency_id].code
      to   = @.get("currency").code

      if @currency_id == organisation.currency_id
        @inverse = true
        tmp  = from
        from = to
        to   = tmp
      else
        @inverse = false

      rate = fx.convert(1, {from: from, to: to}) || @.get("rate")

      @.set({suggest_rate: rate.round(4), rate: rate.round(4)})
      @$input.val(rate.round(4))
    catch e
  # rateEvents
  rateEvents: ->
    self = @
    $('#suggested_exchange_rate').die().on 'click', (event)->
      self.set({rate: self.get("suggest_rate")})
    # Inverted
    $('#suggested_inverted_rate').die().on 'click', (event)->
      if res = prompt("Tipo de cambio invertido:", self.get("suggest_inv_rate"))
        res = 1/(res * 1)
        self.set({rate: res.round(4)})
  # gets the rates from a server form money.js
  getRates: ->
    self = @
    # 'http://openexchangerates.org/latest.json'
    #$.getJSON "/exchange_rates", (data) =>
      # Check money.js has finished loading:
    if typeof fx != "undefined" and fx.rates
      fx.rates = exchangeRates.rates
      fx.base = exchangeRates.base
    else
      # If not, apply to fxSetup global:
      fxSetup = {
        rates : exchangeRates.rates,
        base : exchangeRates.base
      }

    self.setSuggestRates()


window.ExchangeRate = ExchangeRate
