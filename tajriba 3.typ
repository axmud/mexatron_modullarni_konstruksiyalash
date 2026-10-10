// ============================================================
//  Mexatron Modullarni Konstruksiyalash — 3-tajriba mashgʻuloti
//  Podshipnikning ishqalanish va aylanish xususiyatlari
//  Kompilyatsiya: typst compile mmk_tajriba_mashgulot_3_podshipnik.typ
// ============================================================

#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let headingblue = rgb(20, 50, 120)

#set document(title: "Podshipnikning ishqalanish va aylanish xususiyatlarini tadqiq qilish")
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2cm),
)
#set text(size: 12pt, lang: "uz")
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)", supplement: none)
#show link: set text(fill: blue.darken(20%))
#show heading: set text(fill: headingblue)
#show heading.where(level: 1): set block(above: 1.4em, below: 0.9em)
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.where(kind: image): set figure(supplement: "Rasm")
#show figure.where(kind: table): set figure(supplement: "Jadval")

// Blok formula (raqamlangan)
#let eq(body) = math.equation(block: true, numbering: "(1)", body)

// ---------------- Sarlavha ----------------
#align(center)[
  #text(size: 20pt, weight: "bold", fill: headingblue)[TAJRIBA MASHGʻULOTI №3]
  #v(0.4cm)
  #text(size: 14pt, weight: "bold")[
    Mavzu: Podshipnikning ishqalanish va aylanish xususiyatlarini tadqiq qilish
  ]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Ishning maqsadi

*Mashgʻulotning maqsadi:* mexatronik modullar va servoyuritgichlarda qoʻllaniladigan podshipnik tugunlarining ishqalanish momentini, aylanishga qarshiligini hamda dinamik tribologik xususiyatlarini tajribaviy tadqiq qilish; Stribeck egri chizigʻini qurish, statik uzilish (_breakaway_) momenti va qovushoq ishqalanish koeffitsientini aniqlash, shuningdek, moylash rejimlarining (quruq, chegaraviy, suyuqlikli) podshipnik samaradorligiga taʼsirini baholash.

*Oʻquv vazifalari:*

+ Mexatronik yuritmalar va pretsizion modullarda podshipnik ishqalanishining pozitsiyalash aniqligi hamda dinamik turgʻunlikka taʼsirini tahlil qilish.
+ Podshipnikning statik uzilish (_static/Coulomb friction_) va qovushoq (_viscous friction_) ishqalanish momentlarini tenzometrik moment datchigi yordamida oʻlchash.
+ Burchak tezlik ($omega$) va yuklama ($F_r, F_a$) oʻzgarishiga bogʻliq holda ishqalanish momentining Stribeck xarakteristikasini tajribaviy qurish.
+ Turli moylash materiallari (suyuq moy, plastik moy, quruq kontakt) uchun podshipnikdagi quvvat isrofini va foydali ish koeffitsientini (FIK) hisoblash.
+ ISO GUM boʻyicha oʻlchash natijalarining statistik noaniqligini baholash.

= Kerakli asbob-uskunalar va dasturiy taʼminot

- *Tajriba stendi:* tezligi rostlanadigan servodvigatel ($0 dots 3000 "rpm"$), tezlik va momentni boshqarish moduli.
- *Tadqiqot podshipniklari:* sharikli dumalash podshipniklari (masalan, 6204-2RS, ochiq turdagi 6000) hamda bronza/teflon sirpanish vtulkalari.
- *Moment datchigi (torque sensor):* tenzometrik reaktiv moment oʻlchagich (diapazoni $0 dots 5 "N" dot "m"$, aniqligi $plus.minus 0.1%$).
- *Aylanish tezligi va burchak datchigi:* optik inkremental enkoder (2500 impuls/aylanish, A, B, Z kanallari).
- *Signal konditsioneri va DAQ:* National Instruments USB-6211 (16-bit ADC, $250 "kS/s"$) maʼlumotlarni yigʻish platasi.
- *Dasturiy muhit:* LabVIEW, Python (NumPy, SciPy, Matplotlib) --- signallarni filtrlash va grafik tahlil uchun.

= Mexatronik modullarda podshipniklarning roli va tribologik asoslari

Mexatronik modullarda (robot boʻgʻinlari, CNC stanok shpindellari, optik skanerlar, SCARA robotlar) podshipniklar mexanik harakatni yoʻnaltiruvchi va yuklamani uzatuvchi eng masʼuliyatli konstruktiv element hisoblanadi. Anʼanaviy mashinasozlikdan farqli ravishda, mexatronikada podshipnik faqat yuk koʻtarish qobiliyati bilan emas, balki *minimal va barqaror ishqalanish momenti*, *nolga yaqin lyuft (backlash)* hamda *yuqori dinamik aniqlik* bilan ham tavsiflanishi shart.

Podshipnikdagi ishqalanish momenti mexatron modulda quyidagi salbiy oqibatlarga olib keladi:

- *Pozitsiyalash xatoligi (stick-slip hodisasi):* past tezliklarda statik ishqalanish ($M_s$) Kulon ishqalanishidan ($M_c$) katta boʻlgani sababli harakat sakrashlar bilan kechadi. Bu mikrokoʻchishlarda noaniqlik keltirib chiqaradi.
- *Energiya isrofi va qizish:* ishqalanish quvvati ($P_"loss" = M_f dot omega$) issiqlikka aylanib, val va korpusning issiqlikdan kengayishiga hamda oʻlchamlar oʻzgarishiga sabab boʻladi.
- *Nochiziqlilik va boshqaruv qiyinchiligi:* ishqalanish momenti tezlik va yoʻnalishga bogʻliq holda keskin nochiziqli xarakterga ega. Bu PID rostlagichda gisterezis va avtotebranishlarni (_hunting_) keltirib chiqaradi.

= Nazariy maʼlumotlar va ishqalanish modellari

== Podshipnikdagi umumiy ishqalanish momenti

Dumalash podshipnigidagi toʻliq ishqalanish momenti $M_f$ bir nechta tashkil etuvchilar yigʻindisidan iborat:

$ M_f = M_0 + M_1 + M_"seal" + M_"drag" $

bunda:

- $M_0$ --- tezlik va moy qovushoqligiga bogʻliq yuklamasiz (gidrodinamik) isrof momenti;
- $M_1$ --- tashqi yuklama ($F_r, F_a$) va podshipnik geometriyasiga bogʻliq kontakt ishqalanish momenti;
- $M_"seal"$ --- podshipnik zichlagich halqalari hosil qiladigan ishqalanish momenti;
- $M_"drag"$ --- moy vannasida aylanishdagi gidrodinamik qarshilik momenti.

Palmgren empirik modeliga koʻra yuklamasiz isrof momenti $M_0$ (N·mm) quyidagicha hisoblanadi:

$ M_0 = cases(
  10^(-7) dot f_0 dot (nu_0 n)^(2\/3) dot d_m^3 \, quad & "agar" nu_0 n >= 2000,
  160 dot 10^(-7) dot f_0 dot d_m^3 \, quad & "agar" nu_0 n < 2000,
) $

bunda $f_0$ --- podshipnik turi va moylash usuliga bogʻliq koeffitsient ($1.5 dots 5$), $nu_0$ --- moyning kinematik qovushoqligi (mm#super[2]/s), $n$ --- val aylanish chastotasi (rpm), $d_m = (d + D) \/ 2$ --- podshipnikning oʻrtacha diametri (mm).

Tashqi yuklamadan kelib chiquvchi moment:

$ M_1 = f_1 dot P_1 dot d_m $

bunda $f_1$ --- podshipnik turiga bogʻliq yuklama koeffitsienti, $P_1$ --- keltirilgan ekvivalent yuklama.

== Stribeck ishqalanish modeli va moylash rejimlari

Mexatronik tizimlarda ishqalanish xarakteristikasini tahlil qilishda *Stribeck modeli* keng qoʻllaniladi. Burchak tezlik $omega$ ga bogʻliq holda ishqalanish momenti quyidagicha ifodalanadi:

$ M_f (omega) = [M_c + (M_s - M_c) e^(-(|omega| \/ omega_s)^2)] "sgn"(omega) + b omega $

bunda:

- $M_c$ --- Kulon (quruq dinamik) ishqalanish momenti;
- $M_s$ --- statik uzilish (_breakaway/stiction_) momenti ($M_s > M_c$);
- $omega_s$ --- Stribeck chegara tezligi;
- $b$ --- qovushoq (_viscous_) ishqalanish koeffitsienti;
- $"sgn"(omega)$ --- ishora funksiyasi.

#figure(
  {
    set text(size: 8pt)
    cetz.canvas(length: 1.05cm, {
      import cetz.draw: *

      // Oʻqlar
      line((0, 0), (8.6, 0), stroke: 0.9pt, mark: (end: "straight"))
      line((0, 0), (0, 5.4), stroke: 0.9pt, mark: (end: "straight"))
      content((8.0, -0.4), [burchak tezlik $omega$])
      content((1.25, 5.6), [ishqalanish momenti $M_f$])

      // Mʼs va Mc sathlari
      line((0, 4.2), (8, 4.2), stroke: (paint: luma(150), thickness: 0.6pt, dash: "dashed"))
      line((0, 2.2), (8, 2.2), stroke: (paint: luma(150), thickness: 0.6pt, dash: "dashed"))
      line((1.8, 0), (1.8, 2.4), stroke: (paint: luma(150), thickness: 0.6pt, dash: "dashed"))
      content((-0.45, 4.2), [$M_s$])
      content((-0.45, 2.2), [$M_c$])
      content((1.8, -0.35), [$omega_s$])

      // Rejim chegaralari
      line((1.2, 0), (1.2, 4.9), stroke: (paint: blue, thickness: 0.8pt, dash: "dotted"))
      line((3.5, 0), (3.5, 4.9), stroke: (paint: blue, thickness: 0.8pt, dash: "dotted"))
      content((0.6, 4.75), text(size: 6.5pt, fill: blue.darken(30%))[I \ chegaraviy])
      content((2.35, 4.75), text(size: 6.5pt, fill: blue.darken(30%))[II \ aralash])
      content((5.8, 4.75), text(size: 6.5pt, fill: blue.darken(30%))[III \ gidrodinamik])

      // Stribeck egri chizigʻi
      bezier((0, 4.2), (2.5, 2.0), (0.6, 2.0), (1.5, 1.8), stroke: 1.5pt + red.darken(20%))
      bezier((2.5, 2.0), (8, 4.5), (4.5, 2.6), (6.5, 3.5), stroke: 1.5pt + red.darken(20%))

      // Qovushoq qarshilik
      line((4.0, 2.75), (6.5, 4.05), stroke: 0.9pt + purple, mark: (end: "straight"))
      content((5.0, 3.75), text(size: 6.5pt, fill: purple)[qovushoq qarshilik ($b omega$)])

      // Nuqtalar
      circle((0, 4.2), radius: 0.07, fill: red, stroke: none)
      circle((1.8, 1.9), radius: 0.07, fill: red, stroke: none)
      content((2.0, 1.55), text(size: 6.5pt)[min. moment])
    })
  },
  caption: [Podshipnik ishqalanishining Stribeck egri chizigʻi va moylash rejimlari],
) <fig-stribeck>

Stribeck xarakteristikasi uchta asosiy sohani qamrab oladi (@fig-stribeck):

+ *Chegaraviy moylash rejimi (boundary lubrication):* juda past tezliklarda ($omega approx 0$) metall sirtlar bevosita mexanik kontaktda boʻladi. Ishqalanish momenti maksimal ($M_s$).
+ *Aralash moylash rejimi (mixed lubrication):* tezlik ortishi bilan mikrobortiqlar orasiga moy plyonkasi kirib boradi va ishqalanish momenti keskin kamayadi ($M_s -> M_c$).
+ *Gidrodinamik moylash rejimi (hydrodynamic / elastohydrodynamic):* metall sirtlar moy qatlami bilan toʻliq ajraladi. Tezlik oshgani sari qovushoq ishqalanish ($b omega$) hisobiga moment chiziqli ortib boradi.

= Tajriba stendining konstruksiyasi va oʻlchash zanjiri

Tajriba stendining strukturaviy elektromexanik sxemasi va signal zanjiri @fig-stand da keltirilgan.

#figure(
  {
    set text(size: 7.5pt)
    let b(body) = align(center, body)
    let small(body) = text(size: 6.5pt, body)
    diagram(
      node-stroke: 0.8pt + headingblue,
      node-fill: blue.lighten(93%),
      node-corner-radius: 3pt,
      node-inset: 4pt,
      spacing: (6mm, 12mm),
      edge-stroke: 1pt + headingblue,

      node((0, 0), b[Servodvigatel \ drayveri], width: 2.2cm, height: 1.2cm, fill: yellow.lighten(80%)),
      node((1, 0), b[Servodvigatel], width: 2.2cm, height: 1.2cm),
      node((2, 0), b[Tenzometrik \ moment datchigi], width: 2.4cm, height: 1.2cm, fill: orange.lighten(80%)),
      node((3, 0), b[Tadqiqot \ podshipnigi], width: 2.2cm, height: 1.2cm, fill: red.lighten(85%)),
      node((4, 0), b[Optik enkoder \ (2500 imp/ayl)], width: 2.4cm, height: 1.2cm, fill: orange.lighten(80%)),
      node((3, -0.9), small[$F_r$ (radial yuklama)], stroke: none, fill: none),
      node((3, 1), b[NI DAQ \ (USB-6211)], width: 2.2cm, height: 1.1cm, fill: green.lighten(85%)),
      node((1, 1), b[Kompyuter \ (LabVIEW / Python)], width: 2.6cm, height: 1.1cm, fill: purple.lighten(88%)),

      edge((0, 0), (1, 0), "-|>", label: small[quvvat], label-sep: 6pt),
      edge((1, 0), (2, 0), "=", label: small[val], label-sep: 6pt),
      edge((2, 0), (3, 0), "=", label: small[val], label-sep: 6pt),
      edge((3, 0), (4, 0), "=", label: small[val], label-sep: 6pt),
      edge((3, -0.9), (3, 0), "-|>", stroke: 1pt + red),
      edge((2, 0), (2, 1), (3, 1), "-|>", label: small[$V_M$], label-pos: 0.25, label-side: right),
      edge((4, 0), (4, 1), (3, 1), "-|>", label: small[A, B impulslar], label-pos: 0.25, label-side: left),
      edge((3, 1), (1, 1), "-|>", label: small[USB], label-sep: 6pt),
      edge((1, 1), (0, 1), (0, 0), "-|>", label: small[$omega^*$ buyruq], label-pos: 0.75, label-side: left),
    )
  },
  caption: [Podshipnik ishqalanish momentini oʻlchovchi laboratoriya stendining strukturaviy sxemasi],
) <fig-stand>

Dumalash podshipnigining elementlari va unga taʼsir etuvchi kuchlar @fig-bearing da tasvirlangan.

#figure(
  {
    set text(size: 8pt)
    cetz.canvas(length: 1.1cm, {
      import cetz.draw: *

      // Tashqi halqa
      circle((0, 0), radius: 2.2, fill: luma(225), stroke: 0.9pt)
      circle((0, 0), radius: 1.7, fill: white, stroke: 0.9pt)
      // Ichki halqa
      circle((0, 0), radius: 1.1, fill: luma(205), stroke: 0.9pt)
      circle((0, 0), radius: 0.6, fill: white, stroke: 0.9pt)
      // Sharchalar
      for i in range(8) {
        let a = i * 45deg
        circle((1.4 * calc.cos(a), 1.4 * calc.sin(a)), radius: 0.28, fill: orange.lighten(60%), stroke: 0.8pt)
      }

      // Markaz va oʻqlar
      line((-2.6, 0), (2.6, 0), stroke: (thickness: 0.5pt, dash: "dash-dotted"))
      line((0, -2.6), (0, 2.6), stroke: (thickness: 0.5pt, dash: "dash-dotted"))
      circle((0, 0), radius: 0.05, fill: black)
      content((-0.2, -0.2), text(size: 7pt)[$O$])

      // Radial yuklama
      line((0, 0), (0, -1.85), stroke: 1.4pt + blue, mark: (end: "straight"))
      content((0.95, -2.0), text(size: 7.5pt, fill: blue)[radial yuklama $F_r$])

      // Aylanish (ichki halqa)
      arc((0, 0), start: 45deg, stop: 120deg, radius: 0.95, anchor: "origin", stroke: 1.3pt + red, mark: (end: "straight"))
      content((0.15, 0.62), text(size: 7pt, fill: red)[$omega$])

      // Ishqalanish momenti (tashqi halqa)
      arc((0, 0), start: 135deg, stop: 60deg, radius: 2.45, anchor: "origin", stroke: 1.3pt + green.darken(35%), mark: (end: "straight"))
      content((0, 2.8), text(size: 7.5pt, fill: green.darken(35%))[ishqalanish $M_f$])

      // Oʻlchamlar
      line((0, 0), (-0.42, -0.42), stroke: 0.5pt + luma(90), mark: (end: "straight"))
      content((-0.55, -0.2), text(size: 6.5pt)[$r$])
      line((0, 0), (0.78, -0.78), stroke: 0.5pt + luma(90), mark: (end: "straight"))
      content((0.75, -0.45), text(size: 6.5pt)[$R_i$])
      line((0, 0), (1.7, 0), stroke: 0.5pt + luma(90), mark: (end: "straight"))
      content((1.25, -0.2), text(size: 6.5pt)[$R_o$])
    })
  },
  caption: [Dumalash podshipnigi elementlari va unga taʼsir etuvchi kuchlar sxemasi],
) <fig-bearing>

== Tenzometrik moment datchigi va oʻlchash zanjiri

Ishqalanish momentini yuqori aniqlikda oʻlchash uchun Wheatstone koʻprigi koʻrinishida ulangan folgali tenzorezistorlardan foydalaniladi. Datchikning chiqish kuchlanishi:

$ V_"out" = V_"ex" dot G_f / 4 dot (epsilon_1 - epsilon_2 + epsilon_3 - epsilon_4) $

bunda $V_"ex"$ --- koʻprikning taʼminot kuchlanishi ($5 "V"$ DC), $G_f$ --- tenzosezgirlik koeffitsienti ($G_f approx 2.0$), $epsilon_i$ --- elastik val sirtidagi deformatsiyalar. Tenzorezistorlar val oʻqiga $plus.minus 45 degree$ ostida oʻrnatilganda, ular qayd etadigan bosh deformatsiya bilan moment $M_f$ orasidagi bogʻliqlik:

$ epsilon_(45 degree) = gamma / 2 = tau / (2 G) = M_f / (2 G W_p) = (8 M_f) / (pi d^3 G) $

bunda $W_p = pi d^3 \/ 16$ --- val kesimining qutb qarshilik momenti, $d$ --- datchik elastik valining diametri, $G$ --- siljish moduli.

= Laboratoriya topshiriqlari va tajriba tartibi

== 1-topshiriq: statik uzilish momenti $M_s$ va Kulon ishqalanishini aniqlash

+ Tajriba stendini elektr tarmogʻiga ulang va DAQ platasining datchiklar bilan aloqasini tekshiring.
+ Servodvigatelni juda past tezlik rejimiga oʻtkazing ($omega = 0.1 dots 1.0 "rpm"$).
+ Dvigatelni asta-sekin harakatlantirib, podshipnik joyidan siljigan paytdagi maksimal moment $M_s$ ni tenzodatchik orqali qayd eting.
+ Harakat barqarorlashgandan keyingi oʻrtacha moment qiymatini Kulon ishqalanishi $M_c$ sifatida yozib oling.

== 2-topshiriq: Stribeck xarakteristikasini qurish

+ Aylanish chastotasini $0.5, 5, 20, 50, 100, 300, 600, 1200, 2000, 3000 "rpm"$ qiymatlarida bosqichma-bosqich oshirib boring.
+ Har bir tezlik rejimida kamida $10 "s"$ davomida moment $M_f$ va tezlik $omega$ signallarini $1000 "Hz"$ chastotada diskretlang.
+ Tajribani uch xil moylash holati uchun takrorlang:
  - yuvilgan quruq (moylanmagan) podshipnik;
  - suyuq mineral moy bilan moylangan podshipnik ($nu_0 = 46 "cSt"$);
  - plastik konsistent moy bilan toʻldirilgan podshipnik (litiyli surkov, NLGI 2).

== 3-topshiriq: radial yuklamaning ishqalanishga taʼsirini tadqiq qilish

+ Podshipnik korpusiga vertikal yoʻnalishda $F_r = 0, 50, 100, 200, 350, 500 "N"$ radial yuklamalarni qoʻying.
+ Oʻzgarmas tezlikda ($omega = 500 "rpm"$) ishqalanish momentining yuklamaga bogʻliqligini oʻlchang.

= Tajriba natijalari

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr),
      align: center + horizon,
      stroke: none,
      inset: (x: 4pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*№*],
        [*Tezlik \ $n$ (rpm)*],
        [*Burchak tezlik \ $omega$ (rad/s)*],
        [*Quruq \ $M_f$*],
        [*Suyuq moy \ $M_f$*],
        [*Plastik moy \ $M_f$*],
      ),
      table.hline(stroke: 0.5pt),
      [1], [0.5], [0.052], [14.5], [12.2], [18.5],
      [2], [5.0], [0.524], [11.2], [8.4], [15.2],
      [3], [20.0], [2.094], [10.8], [6.1], [12.8],
      [4], [50.0], [5.236], [11.0], [5.2], [11.0],
      [5], [100.0], [10.472], [11.4], [5.8], [11.5],
      [6], [300.0], [31.416], [12.5], [7.4], [13.8],
      [7], [600.0], [62.832], [14.2], [9.8], [17.2],
      [8], [1200.0], [125.664], [17.5], [14.1], [22.6],
      [9], [2000.0], [209.440], [21.8], [19.5], [29.4],
      [10], [3000.0], [314.159], [27.2], [25.8], [38.1],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Tezlik va moylash turiga bogʻliq holda ishqalanish momenti $M_f$ (N·mm)],
) <tab-speed>

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (auto, 1fr, 1fr, 1fr, 1fr),
      align: center + horizon,
      stroke: none,
      inset: (x: 4pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*№*],
        [*Radial yuklama \ $F_r$ (N)*],
        [*Oʻlchangan moment \ $M_f$ (N·mm)*],
        [*Yuklama ulushi \ $M_1$ (N·mm)*],
        [*Quvvat isrofi \ $P_"loss"$ (W)*],
      ),
      table.hline(stroke: 0.5pt),
      [1], [0], [8.8], [0.0], [0.46],
      [2], [50], [10.2], [1.4], [0.53],
      [3], [100], [11.8], [3.0], [0.62],
      [4], [200], [15.1], [6.3], [0.79],
      [5], [350], [20.2], [11.4], [1.06],
      [6], [500], [25.6], [16.8], [1.34],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Radial yuklama $F_r$ ning ishqalanish momentiga taʼsiri ($n = 500 "rpm"$)],
) <tab-load>

= Namunaviy hisob

*Berilgan maʼlumotlar:* podshipnik 6204-2RS ($d = 20 "mm"$, $D = 47 "mm"$, $d_m = 33.5 "mm"$); aylanish chastotasi $n = 1200 "rpm"$ ($omega = 125.66 "rad/s"$); suyuq moyning kinematik qovushoqligi $nu_0 = 46 "cSt"$ (mm#super[2]/s); yuklamasiz moylash koeffitsienti $f_0 = 2.0$; radial yuklama $F_r = 200 "N"$.

*1. Gidrodinamik koʻrsatkich $nu_0 n$ ni aniqlash:*

$ nu_0 n = 46 times 1200 = 55 thin 200 > 2000 $

*2. Yuklamasiz gidrodinamik isrof momenti $M_0$:*

$ M_0 = 10^(-7) dot f_0 dot (nu_0 n)^(2\/3) dot d_m^3 = 10^(-7) dot 2.0 dot (55 thin 200)^(2\/3) dot 33.5^3 $

$ (55 thin 200)^(2\/3) approx 1450.1, quad quad 33.5^3 = 37 thin 595.4 $

$ M_0 = 10^(-7) dot 2.0 dot 1450.1 dot 37 thin 595.4 approx 10.90 "N" dot "mm" = 0.0109 "N" dot "m" $

*3. Yuklama ostidagi kontakt ishqalanish momenti $M_1$* (sharikli podshipnik uchun $f_1 = 0.0007$):

$ M_1 = f_1 dot F_r dot d_m = 0.0007 dot 200 dot 33.5 = 4.69 "N" dot "mm" $

*4. Toʻliq nazariy ishqalanish momenti:*

$ M_(f,"naz") = M_0 + M_1 = 10.90 + 4.69 = 15.59 "N" dot "mm" $

*5. Podshipnikdagi quvvat isrofi:*

$ P_"loss" = M_(f,"naz") dot omega = (15.59 dot 10^(-3) "N" dot "m") dot 125.66 "rad/s" approx 1.96 "W" $

= Metrologik tahlil va noaniqlikni baholash

ISO GUM (_Guide to the Expression of Uncertainty in Measurement_) boʻyicha $n = 6$ marta takrorlangan $M_f$ oʻlchashlari natijasi @tab-unc da keltirilgan.

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (auto, 1fr, 1fr, 1fr, 1fr),
      align: center + horizon,
      stroke: none,
      inset: (x: 4pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*Oʻlchash \ №*],
        [*Moment \ $M_(f,i)$ (N·mm)*],
        [*Oʻrtacha \ $macron(M)_f$ (N·mm)*],
        [*Chetlashish \ $(M_i - macron(M))$*],
        [*Chetlashish \ kvadrati*],
      ),
      table.hline(stroke: 0.5pt),
      [1], [14.1], table.cell(rowspan: 6)[14.25], [$-0.15$], [0.0225],
      [2], [14.4], [$+0.15$], [0.0225],
      [3], [14.0], [$-0.25$], [0.0625],
      [4], [14.3], [$+0.05$], [0.0025],
      [5], [14.5], [$+0.25$], [0.0625],
      [6], [14.2], [$-0.05$], [0.0025],
      table.hline(stroke: 0.5pt),
      table.cell(colspan: 4, align: right)[*Yigʻindi $sum (M_i - macron(M))^2$*], [*0.175*],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Oʻlchash natijalarining statistik tahlili ($n = 6$, $1200 "rpm"$)],
) <tab-unc>

A turdagi standart noaniqlik:

$ u_A (macron(M)_f) = sqrt((sum (M_i - macron(M))^2) / (n (n - 1))) = sqrt(0.175 / (6 times 5)) approx 0.076 "N" dot "mm" $

B turdagi (datchik pasporti boʻyicha) noaniqlik:

$ u_B = Delta_"datchik" / sqrt(3) = 0.1 / 1.732 approx 0.058 "N" dot "mm" $

Jamlangan standart noaniqlik:

$ u_c = sqrt(u_A^2 + u_B^2) = sqrt(0.076^2 + 0.058^2) approx 0.096 "N" dot "mm" $

Kengaytirilgan noaniqlik ($p = 95%$, Styudent koeffitsienti $k = 2.57$):

$ U = k dot u_c = 2.57 times 0.096 approx 0.25 "N" dot "mm" $

Yakuniy oʻlchash natijasi: $M_f = (14.25 plus.minus 0.25) "N" dot "mm"$ ($p = 95%$).

= Nazorat savollari

+ Stribeck egri chizigʻida chegaraviy, aralash va gidrodinamik moylash rejimlarining paydo boʻlish mexanizmlarini tushuntiring.
+ Podshipnikdagi statik uzilish (_breakaway_) momenti $M_s$ nima uchun Kulon momenti $M_c$ dan katta boʻladi?
+ Mexatronik servoyuritgichlarda stick-slip hodisasi paydo boʻlishining sabablari va uning pozitsiyalash aniqligiga taʼsiri qanday?
+ Palmgren tenglamasiga koʻra yuklamasiz isrof momenti $M_0$ ga qaysi parametrlar eng kuchli taʼsir koʻrsatadi?
+ Tenzometrik moment datchigida Wheatstone koʻprigi nima uchun toʻliq (_full bridge_) sxemada yigʻiladi?
+ Plastik va suyuq moylarning past hamda yuqori burchak tezliklardagi ishqalanish momentiga taʼsiridagi farqlarni izohlang.
+ Podshipnik zichlagichlari ($M_"seal"$) va moy sathi ($M_"drag"$) mexatronik modul quvvat isrofiga qanday taʼsir qiladi?
+ Karnopp va LuGre ishqalanish modellarining anʼanaviy Kulon modelidan afzalligi nimada va ular kompyuter simulyatsiyasida qanday qoʻllaniladi?
+ ISO GUM boʻyicha A va B turdagi oʻlchash noaniqliklarining farqini tushuntiring.
+ Yuqori aniqlikdagi CNC shpindel podshipniklarida oldindan zoʻriqtirish (_preload_) kuchining ishqalanish momenti hamda bikrlikka taʼsirini tushuntiring.
