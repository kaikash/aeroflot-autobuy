puppeteer = require 'puppeteer'
player = require('play-sound')(opts = {})
IOSIF = require './passenger.coffee'

page = null

playMusic = ->
  console.log 'playing music'
  player.play 'music.mp3'


addPassenger = (passenger) ->
  await page.waitFor 'div[role=main]'
  button = await page.$ "a[data-gender-value=\"#{if passenger.male == 'male' then 1 else 0}\"]"
  await button.focus()
  await button.press 'Enter'

  input = await page.$ 'input[title="Фамилия"]'
  await input.type passenger.surname

  input = await page.$ 'input[title="Имя"]'
  await input.type passenger.name

  input = await page.$ 'div.wrapper > div > fieldset > div.row.h-mb--24.nomargin--below-tablet-vertical > div:nth-child(1) > div > div > input'
  await input.type passenger.bday

  input = await page.$ 'input[title="Номер"]'
  await input.focus()
  await input.type passenger.number

  button = await page.$ 'div.wrapper > div > fieldset > div.row.h-mb--24.nomargin--below-tablet-vertical > div:nth-child(6) > div > div.input__helptext > a'
  await button.focus()
  await button.press 'Enter'

  input = await page.$ 'div.row.h-ml--40.nomargin--below-tablet-vertical > div:nth-child(1) > div > div > input'
  await input.type passenger.email

  input = await page.$ 'div.row.h-ml--40.nomargin--below-tablet-vertical > div.col--4.col--stack-tablet-vertical.col--stack-mobile.h-mb--8 > div > div > div > div > input'
  await input.type passenger.phone

  label = await page.$ 'label[for="passangersTermsAndConditions"]'
  await label.click()

  button = await page.$ 'div > div > div.meta__col--center > div > div:nth-child(3) > div.next > a'
  await button.focus()
  await button.press 'Enter'

  playMusic()

buy = (res) ->
  button = await res.$('button.button.button--wide.button--outline.button--bordered')
  await button.focus()
  await button.press 'Enter'
  button = await page.$ 'a.button.button--outline.h-pl--16.h-pr--16.button--bordered'
  await button.focus()
  await button.press 'Enter'

  await page.waitFor 'a.next__button'
  button = await page.$ 'a.next__button'
  await button.focus()
  await button.press 'Enter'

getMinPrice = ->
  await page.goto 'https://www.aeroflot.ru/sb/app/ru-ru#/search?adults=1&cabin=econom&children=0&infants=0&referrer=null&routes=VVO.20181005.MOW&_k=dxl7r7'
  
  await page.waitFor 'a.button.button--wide.button--lg'
  await page.click 'a.button.button--wide.button--lg'
  
  await page.waitFor 'div.frame.h-overflow--hidden.js-tariff-helper.h-pb--0'
  res = await page.$$ 'div.flight-search'
  minPrice = Infinity
  minPriceRes = null
  for x in res
    price = await x.$('div.flight-search__price-text')
    unless price == null
      price = parseInt(await page.evaluate(((elem) => elem.innerText), price))
      if price < minPrice && price >= 15000 
        minPrice = price
        minPriceRes = x
  
  if minPrice <= 15000 
    console.log "min price #{minPrice}"
    return
      minPrice: minPrice
      minPriceRes: minPriceRes
  return null

do -> 
  browser = await puppeteer.launch({headless: false})
  page = await browser.newPage()
  
  {minPrice, minPriceRes} = await getMinPrice()
  await buy minPriceRes
  await addPassenger IOSIF
