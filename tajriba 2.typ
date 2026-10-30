// ============================================================
//  Mexatron Modullarni Konstruksiyalash — 3-tajriba mashgʻuloti
//  Kompilyatsiya: typst compile mmk_tajriba_mashgulot_3.typ
// ============================================================

#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let headingblue = rgb(20, 50, 120)
#let darkteal = rgb(18, 93, 100)

#set document(title: "Valning deformatsiyasi va bikrligini tajribaviy aniqlash")
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2cm),
)
// ===== HOSHIYA =====
#let info = json("fan.json")
#let raqam = 2  // amaliyot raqami
#set document(keywords: (info.fan,))
#set page(header: context {
  set text(size: 9pt, fill: luma(110))
  grid(
    columns: (2fr, auto, 1fr),
    align: (left, center, right),
    info.fan, info.semestr, [Tajriba №#raqam],
  )
  v(-0.5em)
  line(length: 100%, stroke: 0.4pt + luma(170))
})
// ===================
#set text(size: 12pt, lang: "uz", font: info.font)
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
  #text(size: 20pt, weight: "bold", fill: headingblue)[TAJRIBA MASHGʻULOTI №2]
  #v(0.4cm)
  #text(size: 14pt, weight: "bold")[Mavzu: Valning deformatsiyasi va bikrligini tajribaviy aniqlash]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Ishning maqsadi

*Mashgʻulotning maqsadi:* mexatronik modullar, robot manipulyatorlari va servoyuritmalar tarkibidagi vallarning egilish hamda burilish deformatsiyalarini tajribada oʻlchash, valning egilish bikrligi ($k_b$) va burilish bikrligini ($k_t$) aniqlash, tenzometrik oʻlchash usullari va Wheatstone koʻprigi sxemalarini amalda qoʻllash koʻnikmalarini shakllantirish.

*Oʻquv vazifalari:*

+ Bernulli--Eyler balka nazariyasi asosida valning egilish deformatsiyasi va egilish bikrligini hisoblash.
+ Valning burilish deformatsiyasi va burilish bikrligini nazariy hamda tajribaviy aniqlash.
+ Tenzorezistorlar va Wheatstone koʻprigi yordamida val sirtidagi deformatsiyalarni oʻlchash.
+ Nazariy va tajribaviy natijalarni taqqoslash, oʻlchash noaniqligini ISO GUM boʻyicha baholash.

= Kerakli asbob-uskunalar va dasturiy taʼminot

- *Tajriba val namunasi:* doiraviy kesimli poʻlat val ($d = 20 "mm"$, ishchi uzunligi $L = 500 "mm"$, Yung moduli $E approx 210 "GPa"$, siljish moduli $G approx 80 "GPa"$).
- *Yuklash mexanizmi:* egilish uchun statik yuklar toʻplami ($0 dots 1000 "N"$), burilish uchun moment dastagi va yuk richagi ($T = 0 dots 100 "N" dot "m"$).
- *Oʻlchash datchiklari:* induktiv LVDT chiziqli koʻchish datchigi (aniqligi $plus.minus 0.001 "mm"$); soat tipidagi indikator (_dial indicator_); folgali tenzorezistorlar ($R_0 = 120.0 thin Omega$, $G_f = 2.05$); optik inkremental enkoder (burilish burchagi $theta$ ni oʻlchash uchun, 1024 ppr).
- *Signal konditsioneri va DAQ:* Wheatstone koʻprigi modullari bilan tenzometrik kuchaytirgich, 16-bitli analog-raqamli oʻzgartirgich (ADC / National Instruments DAQ).
- *Dasturiy muhit:* LabVIEW, Python (NumPy, Matplotlib) --- maʼlumotlarni yigʻish va grafik tahlil uchun.

= Mexatronik vallarda deformatsiya va bikrlikning ahamiyati

Mexatronik tizimlarda vallar shunchaki harakat va moment uzatuvchi element boʻlib qolmay, yuqori aniqlikdagi pozitsion va dinamik boshqaruv halqasining uzviy qismi hisoblanadi. Servoyuritgichlar, reduktorlar va uzatish mexanizmlaridagi val deformatsiyasi quyidagi salbiy oqibatlarga olib keladi:

- *Kinematik va pozitsion xatolik:* valning burilishi ($theta$) tufayli dvigatel vali burchagi bilan ijrochi modul burchagi oʻrtasida elastik burilish farqi yuzaga keladi.
- *Rezonans chastotasining pasayishi:* val bikrligining ($k_t, k_b$) yetarli emasligi mexatronik tizimning birinchi xususiy tebranish chastotasini ($omega_n = sqrt(k \/ m)$) pasaytiradi. Teskari aloqali boshqaruv tizimida bu tebranishlar va turgʻunsizlikka olib keladi.
- *Podshipniklarning notekis yeyilishi:* egilish deformatsiyasi ($delta$) val tayanchlaridagi podshipniklarning qiyshayishiga va xizmat muddatining qisqarishiga sabab boʻladi.

= Nazariy maʼlumotlar va matematik modellar

== Valning egilish deformatsiyasi va egilish bikrligi

Ikki sharnirli tayanchga erkin qoʻyilgan va oʻrtasida toʻplangan $F$ kuch bilan yuklangan valning egilish tenglamasi Bernulli--Eyler balka nazariyasiga koʻra quyidagicha ifodalanadi:

$ E I (dif^2 w(x)) / (dif x^2) = M(x) $

bunda:

- $w(x)$ --- $x$ kesimdagi egilish (progib), m;
- $E$ --- val materialining elastiklik moduli (Yung moduli), Pa;
- $I$ --- val koʻndalang kesimining ekvatorial inersiya momenti, m#super[4];
- $M(x)$ --- $x$ kesimdagi eguvchi moment, N·m.

Doiraviy kesimli val uchun inersiya momenti:

$ I = (pi d^4) / 64 $

Val oʻrtasidagi maksimal egilish (progib):

$ delta = w_"max" = (F L^3) / (48 E I) = (4 F L^3) / (3 pi E d^4) $

Valning egilish bikrligi ($k_b$) --- birlik egilish deformatsiyasini hosil qilish uchun zarur boʻlgan kuch:

$ k_b = F / delta = (48 E I) / L^3 = (3 pi E d^4) / (4 L^3) quad ["N/m"] $

Val sirtidagi maksimal normal kuchlanish ($sigma_"max"$) va unga mos chiziqli deformatsiya ($epsilon_x$):

$ sigma_"max" = (M_"max" dot (d \/ 2)) / I = ((F L \/ 4) dot (d \/ 2)) / (pi d^4 \/ 64) = (8 F L) / (pi d^3) $

$ epsilon_x = sigma_"max" / E = (8 F L) / (pi E d^3) $

== Valning burilish deformatsiyasi va burilish bikrligi

Valga $T$ buruvchi moment taʼsir etganda, val kesimlari bir-biriga nisbatan $theta$ burchakka buriladi. Guk qonuniga muvofiq:

$ theta = (T L) / (G J_p) $

bunda:

- $G$ --- val materialining siljish moduli (_shear modulus_), Pa;
- $J_p$ --- val kesimining qutb inersiya momenti, m#super[4];
- $L$ --- valning buralayotgan qismi uzunligi, m.

Yaxlit doiraviy kesimli val uchun qutb inersiya momenti:

$ J_p = (pi d^4) / 32 $

Valning burilish bikrligi ($k_t$) --- bir radian burilish burchagiga mos keluvchi moment:

$ k_t = T / theta = (G J_p) / L = (pi G d^4) / (32 L) quad ["N" dot "m/rad"] $

Val sirtidagi maksimal urinma kuchlanish ($tau_"max"$) va siljish deformatsiyasi ($gamma_"max"$):

$ tau_"max" = (T dot (d \/ 2)) / J_p = (16 T) / (pi d^3) $

$ gamma_"max" = tau_"max" / G = (16 T) / (pi G d^3) $

== Tenzometrik oʻlchash va Wheatstone koʻprigi sxemasi

Val sirtidagi kichik elastik deformatsiyalarni ($epsilon approx 10^(-6) dots 10^(-3)$) yuqori aniqlikda oʻlchash uchun tenzorezistorlar qoʻllaniladi. Tenzorezistor qarshiligining nisbiy oʻzgarishi:

$ (Delta R) / R_0 = G_f dot epsilon $

bunda $G_f approx 2.05$ --- tenzosezgirlik koeffitsienti. Kichik qarshilik oʻzgarishi $Delta R$ ni kuchlanish signaliga aylantirish uchun Wheatstone koʻprigi qoʻllaniladi (@fig-bridge):

$ V_"out" = V_"ex" dot G_f / 4 (epsilon_1 - epsilon_2 + epsilon_3 - epsilon_4) $

- *Egilishni oʻlchashda:* valning quyi (choʻziluvchi, $epsilon_1 = +epsilon$) va yuqori (siqiluvchi, $epsilon_2 = -epsilon$) sirtlariga oʻrnatilgan tenzorezistorlar koʻprikning qoʻshni yelkalariga ulanadi. Natijada koʻprik sezgirligi 2 barobar oshadi va harorat taʼsiri avtomatik kompensatsiyalanadi.
- *Burilishni oʻlchashda:* burilishda bosh deformatsiyalar val oʻqiga $+45 degree$ va $-45 degree$ burchak ostida yoʻnalgan boʻladi. Shu sababli tenzorezistorlar $45 degree$ va $135 degree$ ostida joylashtiriladi ($epsilon_1 = +gamma \/ 2$, $epsilon_2 = -gamma \/ 2$).

= Tajriba stendining prinsipial va konstruktiv sxemalari

#figure(
  {
    set text(size: 8pt)
    cetz.canvas(length: 1.1cm, {
      import cetz.draw: *

      // Stend asosi
      rect((-1, -0.5), (11, -0.15), fill: luma(225), stroke: 0.8pt)
      for i in range(25) {
        line((-0.9 + i * 0.5, -0.5), (-1.15 + i * 0.5, -0.8), stroke: 0.5pt + luma(120))
      }

      // Tayanchlar
      line((0, -0.15), (-0.4, -0.5), (0.4, -0.5), close: true, fill: blue.lighten(75%), stroke: 0.8pt)
      line((10, -0.15), (9.6, -0.5), (10.4, -0.5), close: true, fill: blue.lighten(75%), stroke: 0.8pt)

      // Val
      rect((0, -0.15), (10, 0.15), fill: orange.lighten(65%), stroke: 0.8pt)
      content((1.7, 0.45), text(size: 7.5pt)[Poʻlat val ($d = 20 "mm"$)])

      // Egilgan val shakli
      bezier((0, 0), (10, 0), (3, -0.6), (7, -0.6), stroke: (paint: red, thickness: 1.2pt, dash: "dashed"))

      // Kuch
      rect((4.8, 0.15), (5.2, 0.35), fill: red.lighten(50%), stroke: 0.6pt)
      line((5, 1.6), (5, 0.4), stroke: 1.3pt + red.darken(20%), mark: (end: "straight"))
      content((5.35, 1.2), text(size: 10pt)[$arrow(F)$])

      // Tenzorezistorlar
      rect((3.9, 0.15), (4.3, 0.22), fill: black)
      content((3.65, 0.45), text(size: 6.5pt)[$R_2$ (siqilish)])
      rect((3.9, -0.22), (4.3, -0.15), fill: black)

      // LVDT
      rect((4.6, -2.0), (5.4, -1.1), fill: darkteal.lighten(80%), stroke: 0.8pt)
      content((5, -1.55), text(size: 6.5pt)[LVDT])
      line((5, -1.1), (5, -0.5), stroke: 0.8pt)
      circle((5, -0.47), radius: 0.05, fill: black)
      content((3.4, -1.55), text(size: 6.5pt)[$R_1$ (choʻzilish) \ val ostida])

      // Progib
      line((5.8, 0), (5.8, -0.45), stroke: 0.8pt + red, mark: (start: "straight", end: "straight"))
      content((6.1, -0.25), text(size: 8pt)[$delta$])

      // Soat tipidagi indikator
      circle((2.5, 1.25), radius: 0.4, fill: blue.lighten(88%), stroke: 0.8pt)
      content((2.5, 1.25), text(size: 6pt)[Dial])
      line((2.5, 0.85), (2.5, 0.15), stroke: 0.8pt)

      // Oʻlcham
      line((0, 0), (0, -2.5), stroke: (thickness: 0.5pt, dash: "dashed"))
      line((10, 0), (10, -2.5), stroke: (thickness: 0.5pt, dash: "dashed"))
      line((0, -2.35), (10, -2.35), stroke: 0.8pt, mark: (start: "straight", end: "straight"))
      content((7.5, -2.6), text(size: 7.5pt)[Uzunlik $L = 500 "mm"$])
    })
  },
  caption: [Val egilish deformatsiyasini oʻlchash laboratoriya stendi sxemasi],
) <fig-bend>

#figure(
  {
    set text(size: 8pt)
    cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // Mahkamlangan uchi
      rect((-0.5, -1.6), (0, 1.6), fill: luma(110), stroke: 0.8pt)
      for i in range(8) {
        line((-0.5, -1.5 + i * 0.4), (-0.8, -1.2 + i * 0.4), stroke: 0.5pt)
      }
      content((-1.9, 0), text(size: 7.5pt)[Mahkamlangan \ uchi])

      // Val
      circle((0, 0), radius: (0.4, 1.2), fill: luma(215), stroke: 0.8pt)
      line((0, 1.2), (8, 1.2), stroke: 0.8pt)
      line((0, -1.2), (8, -1.2), stroke: 0.8pt)
      circle((8, 0), radius: (0.4, 1.2), fill: luma(240), stroke: 0.8pt)
      line((0, 0), (9.8, 0), stroke: (thickness: 0.5pt, dash: "dash-dotted"))

      // Moment dastagi
      rect((7.8, -1.8), (8.2, 1.8), fill: blue.lighten(65%), stroke: 0.8pt)
      line((8.2, 1.55), (9.5, 1.55), stroke: 1.3pt + red, mark: (end: "straight"))
      content((9.95, 1.55), text(size: 7.5pt)[$arrow(F)$])
      line((7.8, -1.55), (6.5, -1.55), stroke: 1.3pt + red, mark: (end: "straight"))
      content((6.05, -1.55), text(size: 7.5pt)[$arrow(F)$])

      // Buruvchi moment
      arc((9.2, 0), start: -70deg, stop: 70deg, radius: (0.35, 0.9), anchor: "origin", stroke: 1.2pt + darkteal, mark: (
        end: "straight",
      ))
      content((9.9, 0.3), text(size: 10pt, fill: darkteal)[$T$])
      content((9.9, -0.35), text(size: 8pt)[$theta$])

      // Rozetka tenzorezistorlar
      rect((3.4, 0.0), (4.6, 0.8), fill: white, stroke: 0.8pt)
      line((3.7, 0.1), (4.3, 0.7), stroke: 1.2pt + red)
      line((3.7, 0.7), (4.3, 0.1), stroke: 1.2pt + blue)
      content((5.45, 0.6), text(size: 6.5pt, fill: red)[$R_1 (+45 degree)$])
      content((5.45, 0.2), text(size: 6.5pt, fill: blue)[$R_2 (-45 degree)$])
      content((4, 1.5), text(size: 7.5pt)[Tenzorezistorlar rozetkasi])
    })
  },
  caption: [Valning burilish deformatsiyasi ($T, theta$) va $45 degree$ ostida oʻrnatilgan tenzorezistorlar joylashuvi],
) <fig-tors>

#figure(
  {
    set text(size: 8pt)
    cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // Koʻprik yelkalari
      let arm(a, b) = {
        let m = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
        line(a, b, stroke: 0.9pt)
        circle(m, radius: 0.22, fill: orange.lighten(75%), stroke: 0.8pt)
      }
      arm((0, 2), (2, 4))
      arm((2, 4), (4, 2))
      arm((4, 2), (2, 0))
      arm((2, 0), (0, 2))
      content((0.15, 3.35), text(size: 7pt)[$R_1$ (choʻzilish)])
      content((3.85, 3.35), text(size: 7pt)[$R_2$ (siqilish)])
      content((3.85, 0.65), text(size: 7pt)[$R_3$ (choʻzilish)])
      content((0.15, 0.65), text(size: 7pt)[$R_4$ (siqilish)])

      // Tugunlar
      circle((0, 2), radius: 0.08, fill: black)
      content((0.35, 2.3), [A])
      circle((4, 2), radius: 0.08, fill: black)
      content((3.65, 2.3), [B])
      circle((2, 4), radius: 0.08, fill: black)
      content((2.55, 4.3), text(size: 7pt)[$V_"ex" +$])
      circle((2, 0), radius: 0.08, fill: black)
      content((2.5, -0.3), text(size: 7pt)[GND])

      // Taʼminot manbai
      line((2, 4), (2, 5), (-1.5, 5), (-1.5, -1), (2, -1), (2, 0), stroke: 0.9pt)
      circle((-1.5, 2), radius: 0.42, fill: white, stroke: 0.9pt)
      content((-1.5, 2), text(size: 7pt)[$V_"ex"$])

      // Kuchaytirgich va DAQ
      line((0, 2), (-0.5, 2), (-0.5, 1.0), (5.5, 1.0), stroke: 0.9pt)
      line((4, 2), (5.5, 2), stroke: 0.9pt)
      rect((5.5, 0.5), (7.5, 2.5), fill: blue.lighten(85%), stroke: 0.9pt)
      content((6.5, 1.5), text(size: 7.5pt)[Differensial \ kuchaytirgich])
      line((7.5, 1.5), (8.5, 1.5), stroke: 1pt, mark: (end: "straight"))
      rect((8.5, 0.5), (10.5, 2.5), fill: darkteal.lighten(80%), stroke: 0.9pt)
      content((9.5, 1.5), text(size: 7.5pt)[16-bit ADC \ DAQ / PC])
    })
  },
  caption: [Toʻliq Wheatstone koʻprigi (_full bridge_), signal kuchaytirgich va DAQ platasiga ulanish sxemasi],
) <fig-bridge>

#figure(
  {
    set text(size: 7.5pt)
    cetz.canvas(length: 0.95cm, {
      import cetz.draw: *

      // Chap grafik: egilish
      grid(
        (0, 0),
        (4.5, 3.5),
        step: 0.5,
        stroke: 0.2pt + luma(210),
      )
      line((0, 0), (5, 0), stroke: 0.8pt, mark: (end: "straight"))
      line((0, 0), (0, 4), stroke: 0.8pt, mark: (end: "straight"))
      content((4.3, -0.35), [Progib $delta$ [mm]])
      content((0.9, 4.25), [Yuk $F$ [N]])
      line((0, 0), (4, 3.2), stroke: 1.3pt + blue)
      content((3.3, 3.7), text(fill: blue)[Nazariy ($k_b = "const"$)])
      let up = ((0, 0), (1, 0.7), (2, 1.55), (3, 2.45), (4, 3.25))
      let down = ((4, 3.25), (3, 2.35), (2, 1.45), (1, 0.6), (0, 0))
      line(..up, stroke: 0.9pt + red)
      line(..down, stroke: (paint: red, thickness: 0.9pt, dash: "dashed"))
      for p in up { circle(p, radius: 0.06, fill: red, stroke: none) }
      for p in down {
        rect((p.at(0) - 0.06, p.at(1) - 0.06), (p.at(0) + 0.06, p.at(1) + 0.06), fill: red, stroke: none)
      }
      content((2.9, 0.7), text(fill: red)[Tajriba (yuklash / boʻshatish)])

      // Oʻng grafik: burilish
      let x0 = 7
      line((x0, 0), (x0 + 4.2, 3.3), (x0 + 4.2, 0), close: true, fill: blue.lighten(85%), stroke: none)
      grid(
        (x0, 0),
        (x0 + 4.5, 3.5),
        step: 0.5,
        stroke: 0.2pt + luma(210),
      )
      line((x0, 0), (x0 + 5, 0), stroke: 0.8pt, mark: (end: "straight"))
      line((x0, 0), (x0, 4), stroke: 0.8pt, mark: (end: "straight"))
      content((x0 + 4.2, -0.35), [Burchak $theta$ [rad]])
      content((x0 + 1.3, 4.25), [Moment $T$ [N·m]])
      line((x0, 0), (x0 + 4.2, 3.3), stroke: 1.3pt + darkteal)
      content((x0 + 3.2, 3.75), text(fill: darkteal)[$k_t = (Delta T) / (Delta theta)$])
      content((x0 + 2.8, 0.5), [Deformatsiya energiyasi])
    })
  },
  caption: [Tajribaviy egilish ($F$--$delta$) va burilish ($T$--$theta$) grafiklari hamda gisterezis hodisasi],
  placement: auto,
) <fig-curves>

= Laboratoriya topshiriqlari va tajriba tartibi

== 1-topshiriq: valning egilish bikrligini ($k_b$) aniqlash

+ Valni ikki tayanchga joylashtiring va $L = 500 "mm"$ masofani oʻlchab belgilang.
+ LVDT va soat tipidagi indikatorni valning teng oʻrtasiga ($x = L \/ 2$) oʻrnating. Datchik koʻrsatkichlarini nolga sozlang ($V_"out" = 0$).
+ Val oʻrtasiga bosqichma-bosqich yuk osing: $F = 100, 200, 300, 400, 500 "N"$.
+ Har bir yuk qiymatida LVDT va tenzometrik koʻprikdan olinayotgan kuchlanish $V_"out"$ hamda progib $delta$ qiymatlarini @tab-bend ga yozing.
+ Yukni bosqichma-bosqich kamaytirib (boʻshatish yurishi), gisterezis xatoligini aniqlang.

== 2-topshiriq: valning burilish bikrligini ($k_t$) aniqlash

+ Valning bir uchini konsol tarzida qattiq mahkamlang.
+ Ikkinchi erkin uchiga moment richagini oʻrnating va optik enkoderni (burchak datchigini) ulang.
+ Richakka bosqichma-bosqich buruvchi moment qoʻllang: $T = 10, 20, 30, 40, 50 "N" dot "m"$.
+ Har bir momentda burilish burchagi $theta$ ni (gradus va radianlarda) hamda $45 degree$ ostida joylashgan tenzorezistorlar signalini @tab-tors ga qayd eting.

= Tajriba maʼlumotlari va kalibrovka jadvallari

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
        [*Yuk \ $F$ [N]*],
        [*LVDT progibi \ $delta_"taj"$ [mm]*],
        [*Tenzo signal \ $V_"out"$ [mV]*],
        [*Nazariy progib \ $delta_"naz"$ [mm]*],
        [*Bikrlik \ $k_b$ [N/mm]*],
      ),
      table.hline(stroke: 0.5pt),
      [1], [100], [0.158], [1.24], [0.157], [632.9],
      [2], [200], [0.316], [2.48], [0.315], [632.9],
      [3], [300], [0.475], [3.72], [0.472], [631.5],
      [4], [400], [0.635], [4.96], [0.630], [629.9],
      [5], [500], [0.796], [6.21], [0.787], [628.1],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Val egilishi va bikrligini aniqlash natijalari ($L = 500 "mm"$, $d = 20 "mm"$)],
) <tab-bend>

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
        [*Moment \ $T$ [N·m]*],
        [*Burchak \ $theta$ [gradus]*],
        [*Burchak \ $theta$ [rad]*],
        [*Bikrlik \ $k_(t,"taj")$ [N·m/rad]*],
        [*Nisbiy \ xatolik [%]*],
      ),
      table.hline(stroke: 0.5pt),
      [1], [10], [0.231], [0.00403], [2481.3], [1.2],
      [2], [20], [0.463], [0.00808], [2475.2], [1.4],
      [3], [30], [0.696], [0.01214], [2469.1], [1.7],
      [4], [40], [0.929], [0.01621], [2467.6], [1.8],
      [5], [50], [1.163], [0.02029], [2464.2], [1.9],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Val burilishi va burilish bikrligini aniqlash natijalari],
) <tab-tors>

= Namunaviy misol hisobi

*Boshlangʻich parametrlar:* poʻlat val diametri $d = 20 "mm" = 0.020 "m"$, uzunligi $L = 0.50 "m"$, Yung moduli $E = 210 "GPa" = 210 times 10^9 "Pa"$, siljish moduli $G = 80 "GPa" = 80 times 10^9 "Pa"$.

*1. Inersiya momentlarini hisoblash:*

$ I = (pi d^4) / 64 = (pi times (0.020)^4) / 64 = 7.854 times 10^(-9) "m"^4 $

$ J_p = (pi d^4) / 32 = (pi times (0.020)^4) / 32 = 15.708 times 10^(-9) "m"^4 $

*2. Nazariy egilish bikrligi:*

$
  k_(b,"naz") = (48 E I) / L^3 = (48 times (210 times 10^9) times (7.854 times 10^(-9))) / (0.50)^3 \
  = 633 thin 350 "N/m" approx 633.3 "N/mm"
$

*3. Nazariy burilish bikrligi:*

$ k_(t,"naz") = (G J_p) / L = ((80 times 10^9) times (15.708 times 10^(-9))) / 0.50 = 2513.3 "N" dot "m/rad" $

*4. $F = 500 "N"$ yukda oʻlchangan progib va tajribaviy bikrlik:* oʻlchangan progib $delta_"taj" = 0.796 "mm"$.

$ k_(b,"taj") = F / delta_"taj" = (500 "N") / (0.796 "mm") = 628.14 "N/mm" $

Nisbiy chetlashish:

$ Delta k_b = (|k_(b,"naz") - k_(b,"taj")|) / k_(b,"naz") times 100% = (|633.34 - 628.14|) / 633.34 times 100% = 0.82% $

= Metrologik tahlil va xatoliklarni baholash

Oʻlchash natijalarining aniqligi va ishonchliligini baholash uchun ISO GUM tavsiyalariga koʻra $n = 5$ marta takroriy oʻlchashlar statistikasi tahlil qilinadi. Oʻrtacha arifmetik qiymat:

$ macron(delta) = 1 / n sum_(i=1)^n delta_i $

Oʻrtacha kvadratik chetlashish:

$ S_x = sqrt(1 / (n - 1) sum_(i=1)^n (delta_i - macron(delta))^2) $

Styudent koeffitsienti ($t_(alpha, n-1) = 2.776$, ishonchlilik ehtimolligi $alpha = 0.95$) boʻyicha kengaytirilgan oʻlchash noaniqligi:

$ U = t_(alpha, n-1) dot S_x / sqrt(n) $

= Nazorat savollari

+ Mexatronik modul vallarining egilish bikrligi ($k_b$) va burilish bikrligi ($k_t$) tushunchalariga taʼrif bering.
+ Nima uchun reduktor vallarining bikrligi yetarli boʻlmaganda boshqaruv tizimida turgʻunsizlik va tebranishlar yuzaga keladi?
+ Doiraviy kesimning ekvatorial ($I$) va qutb ($J_p$) inersiya momentlari formulalarini keltiring.
+ Bernulli--Eyler balka nazariyasiga koʻra ikki tayanchli valning maksimal progib tenglamasini tushuntiring.
+ Tenzorezistorning sezgirlik koeffitsienti ($G_f$) nima va u metall folgali tenzorezistorlarda qanchaga teng?
+ Burilish deformatsiyasini oʻlchashda tenzorezistorlar nega val oʻqiga $45 degree$ burchak ostida oʻrnatiladi?
+ Toʻliq Wheatstone koʻprigi (_full bridge_) sxemasining yarim va chorak koʻprik sxemalariga nisbatan afzalliklari nimada?
+ Tajribada kuzatilgan elastik gisterezis hodisasining sabablari nimada?
+ LVDT datchigining ishlash prinsipi va uning soat tipidagi indikatordan aniqlik boʻyicha farqini tushuntiring.
+ Val diametri $d$ ikki barobar oshirilsa, uning egilish bikrligi $k_b$ necha barobar ortadi?
