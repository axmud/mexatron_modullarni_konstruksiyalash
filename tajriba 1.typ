// ============================================================
//  Mexatron Modullarni Konstruksiyalash — 2-tajriba mashgʻuloti
//  Kompilyatsiya: typst compile mmk_tajriba_mashgulot_2.typ
// ============================================================

#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let headingblue = rgb(20, 50, 120)

#set document(title: "Mexatron modul konstruksiyasining geometrik parametrlarini oʻlchash")
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2cm),
)
// ===== HOSHIYA =====
#let info = json("fan.json")
#let raqam = 1  // amaliyot raqami
#set document(keywords: (info.fan,))
#set page(header: context {
  set text(size: 9pt, fill: luma(110))
  grid(
    columns: (1fr, auto, 1fr),
    align: (left, center, right),
    info.fan, info.semestr, [Tajriba №#raqam],
  )
  v(-0.5em)
  line(length: 100%, stroke: 0.4pt + luma(170))
})
// ===================
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
  #text(size: 20pt, weight: "bold", fill: headingblue)[TAJRIBA MASHGʻULOTI №1]
  #v(0.4cm)
  #text(size: 14pt, weight: "bold")[
    Mavzu: Mexatron modul konstruksiyasining geometrik parametrlarini oʻlchash, datchiklar kalibrovkasi va metrologik tahlili
  ]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Ishning maqsadi

*Amaliy maqsad:* mexatronik modullarning mexanik va konstruktiv geometrik parametrlarini (chiziqli oʻlchamlar, shakl va joylashuv chetlashishlari, surilish va burchak koʻchishlari) zamonaviy kontaktli hamda kontaktsiz datchiklar yordamida oʻlchash, kalibrovka qilish va metrologik koʻrsatkichlarini baholash koʻnikmalarini shakllantirish.

*Oʻquv vazifalari:*

+ Mexatronik oʻlchash tizimlarining koʻp pogʻonali funksional va strukturaviy tuzilishini oʻrganish.
+ LVDT (_Linear Variable Differential Transformer_) koʻchish datchigining ishlash prinsipi va statik xarakteristikalarini tadqiq etish.
+ Optik inkremental enkoderlar yordamida burchakli hamda chiziqli koʻchishlarni kvadratur impulsli sanash usulida oʻlchash.
+ Sigʻimiy (_capacitive_) va tenzometrik (_strain gauge_) datchiklarning geometrik sezgirligini tahlil qilish.
+ Lazerli triangulyatsion va kontaktsiz optik oʻlchash metodologiyasini koʻrib chiqish.
+ Oʻlchash natijalariga matematik-statistik ishlov berish, absolyut hamda nisbiy xatoliklarni, oʻrtacha kvadratik chetlashishni va oʻlchash noaniqligini (ISO GUM standarti boʻyicha) hisoblash.

= Kerakli asbob-uskunalar va dasturiy taʼminot

- *Oʻquv-laboratoriya stendi:* mexatronik modul modeli (chiziqli vintli va aylanma servo yuritgichli modul stendi).
- *Oʻlchov datchiklari va transdyuserlar:* LVDT koʻchish datchigi ($plus.minus 10 "mm"$, sezgirligi $250 "mV/mm"$); optik inkremental enkoder ($N = 1024$ impuls/aylanish); diferensial sigʻimiy koʻchish datchigi ($0 dots 2 "mm"$); tenzometrik deformatsiya datchigi (Wheatstone koʻprigi bilan).
- *Etalon va mexanik oʻlchov vositalari:* raqamli mikrometr ($0 dots 25 "mm"$, $0.001 "mm"$), shtangensirkul ($0 dots 150 "mm"$, $0.01 "mm"$), soat tipidagi indikator ($0 dots 10 "mm"$, $0.01 "mm"$).
- *Elektron apparatura va DAQ:* koʻp kanalli analog-raqamli oʻzgartirgich (DAQ kartasi / STM32F4 / Arduino Mega), ikki kanalli raqamli ossillograf, barqarorlashtirilgan oʻzgarmas tok manbai ($plus.minus 15 "V"$, $+5 "V"$).
- *Dasturiy muhit:* LabVIEW, Python (NumPy, SciPy, Matplotlib) — maʼlumotlarni yigʻish, signallarni raqamli filtrlash va statistik ishlov berish uchun.

= Nazariy maʼlumotlar

== Mexatronik oʻlchash tizimining funksional strukturasi

Mexatronik modul konstruksiyasining geometrik parametrlarini (masofa, qalinlik, tirqish, eksentrisitet, burchak koʻchishi) oʻlchash va nazorat qilish avtomatlashtirilgan boshqaruv tizimining qayta aloqa (_feedback_) zanjiridagi eng masʼuliyatli bosqich hisoblanadi. Oʻlchash tizimi odatda uchta asosiy funksional blokdan tashkil topadi (@fig-block):

+ *Datchik (transducer / sensor):* fizik geometrik kattalikni (masalan, $x$ surilishni) elektr signaliga (kuchlanish $V$, tok $I$, sigʻim $C$ yoki induktivlik $L$) oʻzgartiradi.
+ *Signalni shakllantirish va qayta ishlash bloki (signal conditioner):* filtrlaydi, kuchaytiradi, demodulyatsiya qiladi va analog shakldan raqamli shaklga (ADC) oʻtkazadi.
+ *Hisoblash va tasvirlash bloki (processor / controller):* mikrokontroller yoki kompyuter boʻlib, oʻlchov natijasini kalibrovka tenglamasi boʻyicha hisoblaydi va koʻrsatadi.

#figure(
  {
    set text(size: 8pt)
    let b(body) = align(center, body)
    let small(body) = text(size: 7pt, body)
    diagram(
      node-stroke: 0.8pt + headingblue,
      node-fill: blue.lighten(93%),
      node-corner-radius: 3pt,
      node-inset: 5pt,
      spacing: (8mm, 10mm),
      edge-stroke: 1pt + headingblue,

      node((0, 0), b[*Geometrik parametr* \ $x(t), theta(t)$], width: 2.3cm, height: 1.4cm),
      node((1, 0), b[*Datchik* \ (LVDT, enkoder, \ sigʻimiy datchik)], width: 2.5cm, height: 1.4cm),
      node(
        (2, 0),
        b[*Signal konditsioneri* \ (kuchaytirgich, filtr, \ demodulyator)],
        width: 2.8cm,
        height: 1.4cm,
      ),
      node(
        (3, 0),
        b[*ADC / mikrokontroller* \ (raqamlashtirish va \ kalibrovka)],
        width: 2.8cm,
        height: 1.4cm,
        fill: blue.lighten(80%),
      ),

      edge((0, 0), (1, 0), "-|>", label: small[$x, theta$], label-sep: 14pt),
      edge((1, 0), (2, 0), "-|>", label: small[$V_s (t)$], label-sep: 14pt),
      edge((2, 0), (3, 0), "-|>", label: small[$V_"out"$], label-sep: 14pt),
    )
  },
  caption: [Mexatronik oʻlchash tizimining funksional va strukturaviy blok-sxemasi],
) <fig-block>

== LVDT koʻchish datchigi

LVDT datchigi mexatronik modullarning chiziqli kichik koʻchishlarini ($0.001 "mm"$ dan $100 "mm"$ gacha) yuqori aniqlikda, kontaktsiz va ishqalanishsiz oʻlchash imkonini beradi. U bitta birlamchi ($P$) va ikkita qarama-qarshi ulangan ikkilamchi ($S_1, S_2$) gʻaltak hamda silindrik ferromagnit oʻzakdan iborat (@fig-lvdt). Birlamchi gʻaltakka sinusoidal yuqori chastotali taʼminot kuchlanishi beriladi:

$ V_"in" (t) = V_m sin(omega t) $

Ferromagnit oʻzak markaziy (nol) holatda boʻlganda, ikkilamchi gʻaltaklarda hosil boʻlgan EYuK lar teng va qarama-qarshi boʻladi ($V_(S 1) = V_(S 2)$), shuning uchun umumiy chiqish kuchlanishi nolga teng:

$ V_"out" (t) = V_(S 1)(t) - V_(S 2)(t) = 0 $

Oʻzak markazdan $x$ masofaga surilganda induktiv muvozanat buziladi va chiqish kuchlanishi amplituda hamda faza boʻyicha $x$ surilishga proporsional boʻladi:

$ V_"out" (x, t) = K dot x dot V_m sin(omega t + phi) $

bunda $K$ --- LVDT datchigining sezgirlik koeffitsienti, $phi$ --- faza siljishi.

#figure(
  {
    set text(size: 8pt)
    cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // Birlamchi gʻaltak
      rect((-2.6, 1.0), (2.6, 1.7), fill: orange.lighten(75%), stroke: 0.8pt)
      content((0, 1.35), text(size: 7.5pt)[Birlamchi gʻaltak ($P$) --- taʼminot $V_"in" (t)$])

      // Ikkilamchi gʻaltaklar
      rect((-4.6, -1.7), (-0.5, -1.0), fill: green.lighten(75%), stroke: 0.8pt)
      content((-2.55, -1.35), text(size: 7.5pt)[Ikkilamchi $S_1$])
      rect((0.5, -1.7), (4.6, -1.0), fill: green.lighten(75%), stroke: 0.8pt)
      content((2.55, -1.35), text(size: 7.5pt)[Ikkilamchi $S_2$])

      // Ferromagnit oʻzak
      rect((-1.8, -0.4), (1.8, 0.4), fill: luma(120), stroke: 0.8pt)
      content((0, 0), text(size: 7.5pt, fill: white, weight: "bold")[Ferromagnit oʻzak])

      // Oʻzak shtoki
      line((-4.9, 0), (-1.8, 0), stroke: 1.2pt + red.darken(20%))
      line((1.8, 0), (4.9, 0), stroke: 1.2pt + red.darken(20%))
      line((3.3, 0.55), (4.6, 0.55), stroke: 1pt + red.darken(20%), mark: (end: "straight"))
      content((3.95, 0.85), text(size: 7.5pt)[surilish $x$])

      // Magnit oqim chiziqlari
      arc((-1, 0.4), start: 180deg, stop: 0deg, radius: (1, 0.6), stroke: (
        paint: blue,
        thickness: 0.6pt,
        dash: "dashed",
      ))
      arc((1, -0.4), start: 0deg, stop: -180deg, radius: (1, 0.6), stroke: (
        paint: blue,
        thickness: 0.6pt,
        dash: "dashed",
      ))

      // Chiqish zanjiri
      line((-4.6, -1.35), (-5.1, -1.35), (-5.1, -2.4), (-0.6, -2.4), stroke: 0.8pt)
      line((4.6, -1.35), (5.1, -1.35), (5.1, -2.4), (0.6, -2.4), stroke: 0.8pt)
      circle((-0.6, -2.4), radius: 0.06, fill: black)
      circle((0.6, -2.4), radius: 0.06, fill: black)
      content((0, -2.75), text(size: 8pt)[$V_"out" = V_(S 1) - V_(S 2)$])
    })
  },
  caption: [LVDT datchigining konstruktiv sxemasi va ikkilamchi gʻaltaklarda kuchlanish hosil boʻlishi],
  placement: auto,
) <fig-lvdt>

== Optik inkremental enkoder va kvadratur signal

Aylanma va chiziqli koʻchishlarni raqamli oʻlchashda optik inkremental enkoderlar keng qoʻllaniladi. Enkoder diski shaffof va shaffof boʻlmagan $N$ ta sektordan iborat. Bir-biriga nisbatan $90 degree$ elektr burchakka siljigan ikkita fotodatchik ($A$ va $B$ kanallar) yordamida harakat yoʻnalishi va burchak koʻchishi aniqlanadi (@fig-enc).

#figure(
  {
    set text(size: 8pt)
    cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // Enkoder diski
      circle((0, 0), radius: 2.2, fill: luma(240), stroke: 0.8pt)
      for i in range(12) {
        arc(
          (0, 0),
          start: (i * 30) * 1deg,
          stop: (i * 30 + 15) * 1deg,
          radius: 2.05,
          anchor: "origin",
          mode: "PIE",
          fill: luma(50),
          stroke: none,
        )
      }
      circle((0, 0), radius: 1.2, fill: white, stroke: 0.8pt)
      circle((0, 0), radius: 0.55, fill: luma(235), stroke: 0.8pt)
      content((0, 0), text(size: 7pt)[Oʻq])
      content((0, -2.7), text(size: 7.5pt)[Enkoder diski ($N$ sektor)])

      // Kvadratur signallar
      let x0 = 3.6
      // A kanal
      line((x0, 0.6), (x0 + 6.0, 0.6), stroke: 0.8pt, mark: (end: "straight"))
      line((x0, 0.4), (x0, 2.0), stroke: 0.8pt, mark: (end: "straight"))
      content((x0 + 6.3, 0.6), text(size: 7.5pt)[$t$])
      content((x0 + 0.45, 2.2), text(size: 7.5pt)[kanal $A$])
      line(
        (x0, 0.6),
        (x0 + 0.8, 0.6),
        (x0 + 0.8, 1.7),
        (x0 + 2.0, 1.7),
        (x0 + 2.0, 0.6),
        (x0 + 3.2, 0.6),
        (x0 + 3.2, 1.7),
        (x0 + 4.4, 1.7),
        (x0 + 4.4, 0.6),
        (x0 + 5.5, 0.6),
        stroke: 1.2pt + blue,
      )
      // B kanal
      line((x0, -1.9), (x0 + 6.0, -1.9), stroke: 0.8pt, mark: (end: "straight"))
      line((x0, -2.1), (x0, -0.5), stroke: 0.8pt, mark: (end: "straight"))
      content((x0 + 6.3, -1.9), text(size: 7.5pt)[$t$])
      content((x0 + 0.45, -0.3), text(size: 7.5pt)[kanal $B$])
      line(
        (x0, -1.9),
        (x0 + 1.4, -1.9),
        (x0 + 1.4, -0.8),
        (x0 + 2.6, -0.8),
        (x0 + 2.6, -1.9),
        (x0 + 3.8, -1.9),
        (x0 + 3.8, -0.8),
        (x0 + 5.0, -0.8),
        (x0 + 5.0, -1.9),
        (x0 + 5.5, -1.9),
        stroke: 1.2pt + red,
      )
      // Faza siljishi
      line((x0 + 0.8, -2.2), (x0 + 0.8, 1.8), stroke: (paint: luma(150), thickness: 0.5pt, dash: "dashed"))
      line((x0 + 1.4, -2.2), (x0 + 1.4, 1.8), stroke: (paint: luma(150), thickness: 0.5pt, dash: "dashed"))
      line((x0 + 0.8, -2.45), (x0 + 1.4, -2.45), stroke: 0.7pt, mark: (start: "straight", end: "straight"))
      content((x0 + 1.1, -2.75), text(size: 7pt)[$90 degree$ faza])
    })
  },
  caption: [Optik inkremental enkoder diski va $A$ hamda $B$ kanallardagi kvadratur impulslar],
) <fig-enc>

Optik enkoderning burchak boʻyicha ajratish qobiliyati diskdagi tirqishlar soni $N$ ga bogʻliq:

$
  Delta theta_"min" = 360 degree / N, quad quad Delta theta_"quad" = 360 degree / (4 N) quad ("kvadratur" 4 times "rejimda")
$

Inkremental impulslar soni $P$ orqali umumiy burilish burchagi $theta$ va chiziqli surilish $x$ (vintli uzatma qadami $p$ boʻlganda) quyidagicha hisoblanadi:

$ theta = P / (4 N) times 360 degree, quad quad x = P / (4 N) times p $

== Sigʻimiy (capacitive) diferensial masofa datchigi

Kichik oʻlchamli va kontaktsiz yuqori aniqlikdagi sezgirlik talab etilganda yassi sigʻimiy datchiklar qoʻllaniladi. Tekis plastinalar sigʻimi quyidagicha ifodalanadi:

$ C = (epsilon_0 epsilon_r A) / d $

bunda $epsilon_0 = 8.854 times 10^(-12) "F/m"$ --- elektr doimiysi, $epsilon_r$ --- muhitning nisbiy dielektrik singdiruvchanligi, $A$ --- plastinalarning qoplashish yuzi, $d$ --- plastinalar orasidagi masofa (tirqish).

Plastinalar orasidagi masofa $d = d_0 - x$ koʻrinishida oʻzgarganda (push-pull diferensial sxema, @fig-cap):

$ C_1 = (epsilon A) / (d_0 - x), quad quad C_2 = (epsilon A) / (d_0 + x) $

Diferensial oʻlchash koʻprigi orqali olingan chiqish kuchlanishi $V_"out"$ koʻchish $x$ ga toʻgʻri proporsional boʻladi:

$ V_"out" = V_s dot (C_1 - C_2) / (C_1 + C_2) = V_s dot x / d_0 $

#figure(
  {
    set text(size: 8pt)
    cetz.canvas(length: 1cm, {
      import cetz.draw: *

      rect((-3, 1.0), (3, 1.3), fill: blue.lighten(75%), stroke: 0.8pt)
      content((0, 1.65), text(size: 7.5pt)[Qoʻzgʻalmas yuqori plastina ($C_1$)])
      rect((-3, -1.3), (3, -1.0), fill: blue.lighten(75%), stroke: 0.8pt)
      content((0, -1.65), text(size: 7.5pt)[Qoʻzgʻalmas quyi plastina ($C_2$)])

      rect((-2.5, -0.15), (2.5, 0.15), fill: red.lighten(60%), stroke: 0.8pt)
      content((0, 0.42), text(size: 7.5pt)[Harakatlanuvchi markaziy plastina])

      line((2.8, 0), (3.9, 0), stroke: 1pt + red.darken(20%), mark: (end: "straight"))
      content((4.5, 0), text(size: 7.5pt)[$x$ (surilish)])

      line((-2, 0.15), (-2, 1.0), stroke: 0.7pt, mark: (start: "straight", end: "straight"))
      content((-2.95, 0.6), text(size: 7.5pt)[$d_1 = d_0 - x$])
      line((-2, -0.15), (-2, -1.0), stroke: 0.7pt, mark: (start: "straight", end: "straight"))
      content((-2.95, -0.6), text(size: 7.5pt)[$d_2 = d_0 + x$])
    })
  },
  caption: [Diferensial sigʻimiy (push-pull) koʻchish datchigining konstruksiyasi],
) <fig-cap>

== Tenzometrik (strain gauge) deformatsiya datchigi

Mexatronik konstruksiyadagi mikron darajasidagi egilish va deformatsiyalarni oʻlchashda tenzorezistorlar qoʻllaniladi. Tenzodatchikning rezistiv oʻzgarishi nisbiy deformatsiyaga ($epsilon = Delta L \/ L$) proporsional:

$ (Delta R) / R = S_g dot epsilon $

bunda $S_g$ --- tenzo-sezgirlik koeffitsienti (_gauge factor_): folgali rezistorlar uchun $S_g approx 2.0 dots 2.2$, yarimoʻtkazgichli rezistorlar uchun $S_g approx 100 dots 150$. Oʻlchov signali Wheatstone koʻprigi orqali kuchaytirgichga beriladi:

$ V_"out" = V_s / 4 dot S_g dot (epsilon_1 - epsilon_2 + epsilon_3 - epsilon_4) $

== Lazerli triangulyatsion va optik kontaktsiz oʻlchash

Lazerli triangulyatsion datchiklarda lazer nuri obyekt sirtiga yoʻnaltiriladi va qaytgan nur PSD (_Position Sensitive Detector_) yoki CCD/CMOS chiziqli matritsasiga tushadi. Obyektgacha boʻlgan $x$ masofa oʻzgarganda matritsadagi nur dogʻining $p$ pozitsiyasi oʻzgaradi:

$ x = (f dot L) / (p dot cos(alpha) + f dot sin(alpha)) $

bunda $f$ --- linza fokus masofasi, $L$ --- bazaviy masofa, $alpha$ --- tushish burchagi.

== Statik kalibrovka xarakteristikasi va metrologik xatoliklar

Har qanday geometrik oʻlchash datchigi kalibrovka xarakteristikasi va metrologik koʻrsatkichlar bilan baholanadi (@fig-hyst):

- *Sezgirlik ($S$):* datchik chiqish signalining kirish geometrik kattaligi oʻzgarishiga nisbati, $S = Delta V \/ Delta x$ $["mV/mm"]$.
- *Absolyut oʻlchash xatoligi ($Delta x_i$):* oʻlchangan $x_i$ qiymat bilan etalon $x_"haq"$ qiymat orasidagi farq: $Delta x_i = x_i - x_"haq"$.
- *Nisbiy xatolik ($delta$):* $delta = (Delta x \/ x_"haq") times 100%$.
- *Oʻrtacha kvadratik chetlashish (standart noaniqlik, $sigma$):* $n$ ta takroriy oʻlchov uchun quyidagicha hisoblanadi.
- *Gisterezis xatoligi ($h_"max"$):* toʻgʻri (koʻpayish) va qaytish (kamayish) yurishlaridagi koʻrsatkichlar farqining maksimal qiymati.

$ macron(x) = 1 / n sum_(i=1)^n x_i, quad quad sigma = sqrt(1 / (n - 1) sum_(i=1)^n (x_i - macron(x))^2) $

#figure(
  {
    set text(size: 8pt)
    cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // Oʻqlar
      line((-4.2, 0), (4.6, 0), stroke: 0.8pt, mark: (end: "straight"))
      line((0, -3.1), (0, 3.4), stroke: 0.8pt, mark: (end: "straight"))
      content((5.3, -0.25), text(size: 7.5pt)[surilish $x$ (mm)])
      content((1.5, 3.4), text(size: 7.5pt)[kuchlanish $V_"out"$ (V)])
      content((-0.2, -0.25), text(size: 7.5pt)[$0$])

      // Toʻgʻri yurish
      bezier((-3.5, -2.6), (3.5, 2.7), (-1.5, -1.1), (1.5, 1.3), stroke: 1.3pt + blue)
      // Qaytish yurish
      bezier(
        (3.5, 2.7),
        (-3.5, -2.6),
        (1.5, 1.5),
        (-1.5, -0.9),
        stroke: (paint: red, thickness: 1.3pt, dash: "dashed"),
      )
      content((4.1, 2.95), text(size: 7pt, fill: blue)[toʻgʻri yurish])
      content((-3.2, -2.95), text(size: 7pt, fill: red)[qaytish yurish])

      // Gisterezis
      line((1.0, 0.72), (1.0, 1.18), stroke: 0.8pt + green.darken(30%), mark: (start: "straight", end: "straight"))
      content((2.3, 0.95), text(size: 7pt)[$h_"max"$ (gisterezis)])

      // Yordamchi chiziqlar
      line((-3.5, 0), (-3.5, -2.6), (0, -2.6), stroke: (paint: luma(150), thickness: 0.5pt, dash: "dotted"))
      line((3.5, 0), (3.5, 2.7), (0, 2.7), stroke: (paint: luma(150), thickness: 0.5pt, dash: "dotted"))
      content((-3.5, 0.28), text(size: 7pt)[$-x_"max"$])
      content((3.5, -0.28), text(size: 7pt)[$+x_"max"$])
      content((-0.65, -2.6), text(size: 7pt)[$-V_"max"$])
      content((-0.65, 2.7), text(size: 7pt)[$+V_"max"$])
    })
  },
  caption: [Datchikning statik kalibrovka xarakteristikasi va gisterezis halqasi ($h_"max"$)],
) <fig-hyst>

= Tajriba mashgʻulotini bajarish tartibi

== 1-topshiriq: mexatron modulning statik oʻlchamlarini oʻlchash

+ Mexatronik modulning oʻlchanadigan elementlarini (val diametri, korpus tirqishi, surilish masofasi) koʻzdan kechiring.
+ Raqamli mikrometr hamda soat tipidagi indikator yordamida valning 5 ta turli nuqtasida diametrini oʻlchang va @tab-stat ga yozing.
+ Valning oval-simmetriklik va konsentriklik chetlashishini aniqlang.

== 2-topshiriq: LVDT datchigini kalibrovka qilish va statik xarakteristikasini qurish

+ LVDT datchigining korpusini stendga mahkamlang va harakatlanuvchi oʻzakni mikrometrik surish mexanizmiga ulang.
+ Oʻzakni markaziy (nol) vaziyatga keltiring ($V_"out" = 0.00 "V"$).
+ Mikrometr murvatini $0.5 "mm"$ qadam bilan $+10 "mm"$ gacha (toʻgʻri yurish), soʻngra $-10 "mm"$ gacha (qaytish yurish) surib, chiqish kuchlanishi $V_"out"$ ni yozib boring.
+ Olingan maʼlumotlar asosida $V_"out" = f(x)$ kalibrovka grafigini quring hamda sezgirlik $S$ va gisterezis $h_"max"$ ni hisoblang.

== 3-topshiriq: optik enkoder yordamida burchakli va chiziqli koʻchishni aniqlash

+ Enkoder oʻqini mexatronik modulning vintli yuritgichiga ulang.
+ Mikrokontroller (STM32 / Arduino) impuls sanagich dasturini ishga tushiring.
+ Yuritgichni $30 degree$, $60 degree$, $90 degree$, $180 degree$, $360 degree$ ga buring va sanalgan impulslar soni $P$ ni hamda hisoblangan burchakni @tab-enc ga qayd eting.

== 4-topshiriq: statistik ishlov berish va noaniqlikni hisoblash

+ Modulning tanlangan geometrik oʻlchamini $n = 5$ marta takroran oʻlchang.
+ Oʻrtacha qiymat $macron(x)$, standart chetlashish $sigma$ va ishonchlilik oraligʻi $U$ ($k = 2$) larni hisoblang.

= Oʻlchov natijalari va kalibrovka jadvallari

== LVDT datchigining statik kalibrovka natijalari

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
        [*Etalon surilish \ $x_"haq"$ (mm)*],
        [*Toʻgʻri yurish \ $V_1$ (V)*],
        [*Qaytish yurish \ $V_2$ (V)*],
        [*Farq \ $Delta V = |V_1 - V_2|$*],
        [*Absolyut xato \ $Delta x$ (mm)*],
      ),
      table.hline(stroke: 0.5pt),
      [1], [$-10.0$], [$-2.50$], [$-2.48$], [0.02], [0.08],
      [2], [$-8.0$], [$-2.01$], [$-1.99$], [0.02], [0.04],
      [3], [$-6.0$], [$-1.50$], [$-1.49$], [0.01], [0.02],
      [4], [$-4.0$], [$-1.00$], [$-0.99$], [0.01], [0.01],
      [5], [$-2.0$], [$-0.51$], [$-0.50$], [0.01], [0.02],
      [6], [$0.0$], [$0.00$], [$0.01$], [0.01], [0.01],
      [7], [$+2.0$], [$+0.49$], [$+0.50$], [0.01], [$-0.02$],
      [8], [$+4.0$], [$+1.01$], [$+1.00$], [0.01], [0.02],
      [9], [$+6.0$], [$+1.50$], [$+1.52$], [0.02], [0.04],
      [10], [$+8.0$], [$+2.00$], [$+2.02$], [0.02], [0.05],
      [11], [$+10.0$], [$+2.49$], [$+2.51$], [0.02], [0.06],
      table.hline(stroke: 1pt),
    )
  },
  caption: [LVDT datchigi kalibrovka koʻrsatkichlari ($V_"in" = 5.0 "V"$, $f = 5 "kHz"$)],
) <tab-lvdt>

== Optik enkoder impulslari va burchak koʻchishi

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
        [*Berilgan burchak \ $theta_"haq"$ ($degree$)*],
        [*Sanalgan \ impulslar $P$*],
        [*Hisoblangan burchak \ $theta_"hisob"$ ($degree$)*],
        [*Absolyut xatolik \ $Delta theta$ ($degree$)*],
        [*Nisbiy xatolik \ $delta$ (%)*],
      ),
      table.hline(stroke: 0.5pt),
      [1], [30.0], [341], [29.97], [$-0.03$], [0.10],
      [2], [60.0], [683], [60.03], [$+0.03$], [0.05],
      [3], [90.0], [1024], [90.00], [0.00], [0.00],
      [4], [180.0], [2048], [180.00], [0.00], [0.00],
      [5], [270.0], [3072], [270.00], [0.00], [0.00],
      [6], [360.0], [4096], [360.00], [0.00], [0.00],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Optik enkoder oʻlchov natijalari ($N = 1024$ impuls/aylanish, $4 times$ kvadratur)],
) <tab-enc>

== Statistik ishlov berish natijalari

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (auto, 1fr, 1fr, 1fr),
      align: center + horizon,
      stroke: none,
      inset: (x: 4pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*Oʻlchash №*],
        [*Oʻlchangan diametr \ $x_i$ (mm)*],
        [*Oʻrtachadan chetlashish \ $(x_i - macron(x))$ (mm)*],
        [*Kvadratik chetlashish \ $(x_i - macron(x))^2$ (mm#super[2])*],
      ),
      table.hline(stroke: 0.5pt),
      [1], [20.012], [$+0.003$], [$9.0 times 10^(-6)$],
      [2], [20.008], [$-0.001$], [$1.0 times 10^(-6)$],
      [3], [20.010], [$+0.001$], [$1.0 times 10^(-6)$],
      [4], [20.006], [$-0.003$], [$9.0 times 10^(-6)$],
      [5], [20.009], [$0.000$], [$0.0 times 10^(-6)$],
      table.hline(stroke: 0.5pt),
      [*Oʻrtacha $macron(x)$*], [*20.009 mm*], [*Yigʻindi $sum$*], [$bold(2.0 times 10^(-5) "mm"^2)$],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Mexatronik modul val diametrini takroriy oʻlchash statistikasi ($x_"haq" = 20.000 "mm"$)],
  placement: auto,
) <tab-stat>

= Hisoblash formulalari va misol hisobi

*1. LVDT datchigining sezgirlik koeffitsientini hisoblash:*

$
  S = (V_"max" - V_"min") / (x_"max" - x_"min") = (2.50 - (-2.50)) / (10.0 - (-10.0)) = (5.00 "V") / (20.0 "mm") \ = 0.25 "V/mm" = 250 "mV/mm"
$

*2. Statistik oʻrtacha qiymat va oʻrtacha kvadratik chetlashish:*

$ macron(x) = (20.012 + 20.008 + 20.010 + 20.006 + 20.009) / 5 = 20.009 "mm" $

$ sigma = sqrt((2.0 times 10^(-5)) / (5 - 1)) = sqrt(5.0 times 10^(-6)) = 0.002236 "mm" approx 2.24 thin mu"m" $

*3. Ishonchlilik oraligʻi (kengaytirilgan noaniqlik, $p = 95%$, $k = 2$):*

$ U = k dot sigma / sqrt(n) = 2 dot 0.00224 / sqrt(5) = 0.0020 "mm" = 2.0 thin mu"m" $

Demak, yakuniy oʻlchov natijasi: $X = (20.009 plus.minus 0.002) "mm"$.

= Nazorat savollari va mustaqil topshiriqlar

+ Mexatronik modullarning geometrik parametrlariga qaysi oʻlcham va chetlashishlar kiradi?
+ LVDT datchigida ferromagnit oʻzak nol vaziyatda boʻlganda nima uchun chiqish kuchlanishi nolga teng boʻladi?
+ Optik inkremental enkoderda $A$ va $B$ kanallarning $90 degree$ faza siljishi qanday amaliy ahamiyatga ega?
+ Inkremental va absolyut optik enkoderlarning bir-biridan asosiy konstruktiv hamda funksional farqlarini tushuntiring.
+ Sigʻimiy diferensial koʻchish datchiklarining chiziqliligini oshirish uchun qanday texnik usullar va sxemalar qoʻllaniladi?
+ Tenzorezistorlarning tenzo-sezgirlik koeffitsienti ($S_g$) nima va u folgali hamda yarimoʻtkazgichli tenzorezistorlarda qanday farq qiladi?
+ Lazerli triangulyatsion masofa datchiklarining ishlash prinsipi va afzalliklari nimada?
+ Oʻlchash xatoliklarining qanday turlari (sistematik, tasodifiy, qoʻpol) mavjud va ularni kamaytirish usullari nimalardan iborat?
+ GUM (_Guide to the Expression of Uncertainty in Measurement_) standarti boʻyicha standart va kengaytirilgan oʻlchash noaniqligi qanday hisoblanadi?
+ LVDT datchigining gisterezis xatoligi va uning paydo boʻlish sabablarini izohlang.
