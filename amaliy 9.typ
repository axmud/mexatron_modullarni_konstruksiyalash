// ============================================================
//  Mexatron modullarni konstruksiyalaş — Mustahkamlik hisobi — amaliy maşğulot — Typst versiyasi
//  Kompilyatsiya: typst compile amaliy_9.typ
// ============================================================

#import "@preview/cetz:0.4.2"

#let headingblue = rgb(20, 50, 120)

#set document(title: "Konstruksiyaning mustahkamlik hisobini bajariş")
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2cm),
)
// ===== HOSHIYA =====
#let info = json("fan.json")
#let raqam = 9  // amaliyot raqami
#set document(keywords: (info.fan,))
#set page(header: context {
  set text(size: 9pt, fill: luma(110))
  grid(
    columns: (2fr, auto, 1fr),
    align: (left, center, right),
    info.fan, info.semestr, [Amaliyot №#raqam],
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
#show figure.where(kind: raw): set figure(supplement: "Listing")
#show raw: set text(size: 9pt)
#show raw.where(block: true): set block(fill: rgb(245, 247, 250), inset: 8pt, radius: 3pt, width: 100%)

// Blok formula (raqamlangan)
#let eq(body) = math.equation(block: true, numbering: "(1)", body)

// Çizmalar uçun ranglar
#let pblue = rgb(26, 82, 118)
#let dslate = rgb(44, 62, 80)
#let lbg = rgb(245, 247, 250)

// ---------------- Sarlavha ----------------
#align(center)[
  #set par(justify: false)
  #text(size: 20pt, weight: "bold", fill: headingblue)[AMALIYOT MAŞĞULOTI №9]
  #v(0.4cm)
  #text(
    size: 14pt,
    weight: "bold",
  )[Mavzu: Konstruksiyaning mustahkamlik hisobini bajariş]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Işning maqsadi

*Maşğulotning maqsadi:* mexatron modul konstruksiyasining asosiy elementlarini mustahkamlik, bikrlik, turğunlik va çarçoq mezonlari böyiça tekşiriş usullarini örganiş. 7--8-amaliy maşğulotlarda loyihalangan çiziqli modul misolida quyidagi könikmalarni hosil qiliş:
- yuklama holatlarini, jumladan favqulodda holatni aniqlaş;
- şarik-vintli vintni murakkab kuçlanganlik va turğunlik böyiça hisoblaş;
- tayanç korpusining boltli birikmasini tekşiriş;
- asos plitasining bikrligini pozitsiyalaş aniqligi bilan soliştiriş;
- CAD muhitida çekli elementlar usuli (FEA) bilan tahlil qiliş va tör yaqinlaşuvini tekşiriş;
- natijalar asosida konstruktiv takliflar beriş.

= Dasturiy va texnik taʼminot

+ *CAD/FEA tizimi:* SolidWorks Simulation, Autodesk Inventor Stress Analysis yoki bepul muqobil sifatida FreeCAD FEM (CalculiX hal qiluvçisi bilan).
+ *Python:* analitik tekşiruv hisoblarini avtomatlaştiriş uçun (@lst-vint).
+ *Dastlabki maʼlumotlar:* 7-maşğulotdagi modul parametrlari, 8-maşğulotdagi qattiq tayanç yiğmasi va @tab-mat dagi materiallar xossalari.

= Mustahkamlik hisobining nazariy asoslari

== Hisobning vazifalari va mezonlari

Konstruksiya elementi quyidagi mezonlar böyiça tekşiriladi:
- *mustahkamlik:* qoldiq deformatsiya yoki sinişning yöqligi;
- *bikrlik:* deformatsiyalar ruxsat etilgan qiymatdan oşmasligi;
- *turğunlik:* siqilgan sterjenlarda böylama egiliş yuzaga kelmasligi;
- *çarçoq mustahkamligi:* takroriy yuklamalarda darz paydo bölmasligi.

Har bir mezon zaxira koeffitsienti orqali baholanadi:

$ n = sigma_"lim" / sigma_"his" >= [n] $ <eq-n>

bunda $sigma_"lim"$ --- çegaraviy kattalik (oqiş çegarasi, kritik kuç, çarçoq çegarasi), $sigma_"his"$ --- hisobiy kattalik, $[n]$ --- talab qilinadigan zaxira koeffitsienti. Mexatron modullarda yuklamalar odatda kiçik bölgani uçun köp hollarda hal qiluvçi mezon mustahkamlik emas, balki bikrlik böladi. Çunki mikrometr darajasidagi deformatsiya ham pozitsiyalaş aniqligini buzadi.

== Yuklama holatlari

Hisob kamida ikki yuklama holati uçun bajariladi:
+ *normal işçi rejim:* tezlaniş, işqalaniş va oğirlik kuçlari (7-maşğulot);
+ *favqulodda holat:* karetka mexanik tirgakka tiralib qolganda dvigatel çöqqi momentini rivojlantiradi. Bu holat dastur xatosi yoki enkoder nosozligida yuz berişi mumkin.

Favqulodda holatda vintdagi öq kuçi dvigatel momenti orqali aniqlanadi:

$ F_a = (2 pi eta T_max) / p $ <eq-Fa>

bunda $T_max$ --- dvigatelning çöqqi momenti (servodvigatellarda odatda $3 T_n$), $eta$ --- vint-gayka juftligining FIK, $p$ --- vint qadami.

== Murakkab kuçlanganlik holati

Vint bir vaqtning özida siqiliş (yoki çöziliş) va buralişga işlaydi. Normal va urinma kuçlanişlar:

$ sigma = F_a / A, quad tau = T / W_p, quad A = (pi d_r^2) / 4, quad W_p = (pi d_r^3) / 16 $ <eq-st>

Plastik materiallar uçun ekvivalent kuçlaniş fon Mizes (energetik) nazariyasi böyiça hisoblanadi:

$ sigma_"ekv" = sqrt(sigma^2 + 3 tau^2) <= R_e / [n] $ <eq-mises>

== Egiliş va bikrlik

Ikki uçi şarnirli tayanga örnatilgan va örtasiga $F$ kuç qöyilgan tösinning eng katta egiliş momenti, kuçlanişi va salqiliği:

$ M_max = (F L) / 4, quad sigma = M_max / W, quad f = (F L^3) / (48 E I) $ <eq-beam>

Töğri törtburçak kesim uçun $I = b t^3 \/ 12$, $W = b t^2 \/ 6$. Salqilik qalinlikning kubiga teskari proporsional. Şu sababli kesim balandligini oşiriş bikrlikni oşirişning eng samarali yölidir.

== Siqilgan sterjenning turğunligi

Uzun va ingiçka siqilgan sterjen uçun Eyler kritik kuçi:

$ F_"cr" = (pi^2 E I) / (mu l)^2, quad I = (pi d_r^4) / 64 $ <eq-euler>

bunda $l$ --- siqilgan qism uzunligi, $mu$ --- uzunlikni keltiriş koeffitsienti: qattiq--erkin 2.0; şarnir--şarnir 1.0; qattiq--şarnir 0.7; qattiq--qattiq 0.5. Eyler formulasi faqat sterjenning egiluvçanligi çegaraviy qiymatdan katta bölganda qöllaniladi:

$ lambda = (mu l) / i >= lambda_"pr" = pi sqrt(E / sigma_"pr"), quad i = sqrt(I / A) = d_r / 4 $ <eq-lambda>

bunda $sigma_"pr"$ --- materialning proporsionallik çegarasi.

== Çarçoq mustahkamligi

Simmetrik sikl böyiça özgaruvçi buraliş uçun çarçoq böyiça zaxira koeffitsienti:

$ n_tau = tau_(-1 D) / (K_f tau_a), quad K_f = 1 + q (K_t - 1), quad tau_(-1 D) = k_s k_d tau_(-1) $ <eq-fatigue>

bunda $tau_a$ --- kuçlaniş amplitudasi, $K_t$ --- nazariy kuçlaniş konsentratsiyasi koeffitsienti (masalan, val yelkasidagi galtel uçun), $q$ --- materialning konsentratsiyaga sezgirligi, $k_s$ va $k_d$ --- sirt sifati va ölçam taʼsirini hisobga oluvçi koeffitsientlar, $tau_(-1)$ --- material namunasining çarçoq çegarasi.

== Boltli birikmalar

Kesuvçi kuç işqalaniş orqali uzatiladigan birikmada siljiş bölmaslik şarti:

$ F_v >= (K F_a) / (mu_t z), quad K = 1.3 dots 1.5 $ <eq-slip>

bunda $mu_t$ --- tutaşgan sirtlar orasidagi işqalaniş koeffitsienti, $z$ --- boltlar soni. Agar taşqi kuç birikmani ağdarişga intilsa, boltga qöşimça çöziluvçi kuç $F_b$ taʼsir qiladi. Bunda boltga uning faqat bir qismi ($Phi F_b$, bunda $Phi approx 0.2 dots 0.3$ --- birikmaning yuklama koeffitsienti) uzatiladi. Tutaşgan sirtlar ajralmaslik şarti va boltdagi kuçlaniş:

$ F_b (1 - Phi) < F_v, quad sigma_b = (F_v + Phi F_b) / A_s <= R_(p 0.2) / [n] $ <eq-bolt>

== Çekli elementlar usuli (FEA)

FEA da detal geometriyasi çekli elementlar töriga bölinadi va har bir element uçun muvozanat tenglamalari yeçiladi. Natijaning işonçliligi quyidagilarga boğliq:
- töğri çegaraviy şartlar (mahkamlaş va yuklamalar);
- töğri material xossalari;
- törning yetarliça mayda bölişi.

Tör yaqinlaşuvi (_mesh convergence_) element ölçamini ketma-ket kiçraytirib tekşiriladi. Natijaning nisbiy özgarişi 2--5 % dan kam bölsa, yeçim yaqinlaşgan hisoblanadi. Ötkir içki burçaklarda nazariy kuçlaniş çeksiz katta bölgani uçun FEA natijasi tör maydalaşgan sari çeksiz oşib boradi (singulyarlik). Bunday nuqtalarda real galtel radiusini modellaş kerak.

= Hisobiy sxema va dastlabki maʼlumotlar

Favqulodda holatda (@fig-load) karetka öng tomondagi tirgakka tiralib qoladi va gayka vintni dvigatel tomonga itaradi. Natijada vintning qattiq tayanç bilan gayka orasidagi qismi bir vaqtda siqiliş va buralişga işlaydi. Öq kuçi qattiq tayanç orqali korpusga, söng boltlar va ştiftlar orqali asos plitasiga uzatiladi.

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // Asos
    rect((0, -0.6), (16, 0), fill: luma(225), stroke: 1pt + dslate)
    // Dvigatel, mufta, qattiq tayanç
    rect((0.2, 0.5), (2.4, 2.3), fill: green.lighten(80%), stroke: 1pt + dslate, radius: 0.08)
    content((1.3, 1.4), text(size: 8pt)[Servo-\ dvigatel])
    rect((2.4, 1.1), (3.1, 1.7), fill: orange.lighten(70%), stroke: 1pt + dslate)
    rect((3.1, 0), (4.1, 2.2), fill: blue.lighten(85%), stroke: 1pt + dslate)
    content((3.6, 2.45), text(size: 7.5pt)[qattiq tayanç], anchor: "south")
    // Vint: siqilgan zona
    rect((4.1, 1.25), (12.0, 1.55), fill: red.lighten(70%), stroke: 0.8pt + dslate)
    rect((12.0, 1.25), (14.6, 1.55), fill: luma(190), stroke: 0.8pt + dslate)
    // Gayka va karetka
    rect((10.8, 0.95), (12.0, 1.85), fill: purple.lighten(65%), stroke: 0.8pt + dslate)
    rect((10.2, 1.85), (12.8, 2.3), fill: purple.lighten(85%), stroke: 1pt + dslate)
    content((11.5, 2.55), text(size: 7.5pt)[karetka], anchor: "south")
    // Tirgak
    rect((12.8, 1.7), (13.2, 2.9), fill: dslate, stroke: none)
    line((13.2, 2.9), (13.2, 0), stroke: 1pt + dslate)
    content((13.3, 3.0), text(size: 7.5pt)[mexanik tirgak], anchor: "south-west")
    // Suzuvçi tayanç
    rect((14.6, 0), (15.4, 2.2), fill: blue.lighten(85%), stroke: 1pt + dslate)

    // Kuçlar
    line((10.0, 2.1), (8.4, 2.1), stroke: 1.4pt + red.darken(10%), mark: (start: none, end: ">", fill: red.darken(10%)))
    content((9.2, 2.15), text(size: 8.5pt, fill: red.darken(20%))[$F_a$], anchor: "south")
    line((4.4, 0.7), (6.0, 0.7), stroke: 1.4pt + red.darken(10%), mark: (end: ">", fill: red.darken(10%)))
    content((5.2, 0.65), text(size: 8.5pt, fill: red.darken(20%))[$R = F_a$], anchor: "north")
    // Moment
    arc((0.0, 1.4), start: 120deg, stop: 240deg, radius: 0.6, anchor: "origin", stroke: 1.2pt + red.darken(10%), mark: (
      end: ">",
      fill: red.darken(10%),
    ))
    content((-0.7, 2.1), text(size: 8.5pt, fill: red.darken(20%))[$T_max$], anchor: "south")

    // Siqilgan uzunlik
    line((4.1, 3.5), (12.0, 3.5), stroke: 0.8pt, mark: (start: ">", end: ">", fill: black, scale: 0.6))
    line((4.1, 2.3), (4.1, 3.65), stroke: (thickness: 0.4pt, dash: "dashed"))
    line((12.0, 2.35), (12.0, 3.65), stroke: (thickness: 0.4pt, dash: "dashed"))
    content((8.05, 3.55), text(size: 8pt)[$l_k = 340$ mm --- siqiliş + buraliş zonasi], anchor: "south")
    // Boltlar va ştiftlar
    for x in (3.35, 3.85) {
      line((x, 0.4), (x, -0.55), stroke: (paint: dslate, thickness: 1.2pt))
    }
    content((3.6, -0.65), text(size: 7.5pt)[boltlar, ştiftlar], anchor: "north")
  }),
  caption: [Favqulodda yuklama holatining hisobiy sxemasi (karetka mexanik tirgakka tiralgan)],
) <fig-load>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (auto, 1fr, auto, auto, auto, auto),
      align: (left + horizon, left + horizon, center + horizon, center + horizon, center + horizon, center + horizon),
      stroke: none,
      inset: (x: 5pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*Material*],
        [*Qöllaniliş joyi*],
        [*$E$ \ \[GPa\]*],
        [*$R_e$ ($R_(p 0.2)$) \ \[MPa\]*],
        [*$R_m$ \ \[MPa\]*],
        [*$tau_(-1)$ \ \[MPa\]*],
      ),
      table.hline(stroke: 0.5pt),
      [C55 pölat], [şarik-vintli vint], [210], [420], [700], [175],
      [EN AW-6061-T6], [asos plitasi, korpus, qopqoq], [69], [240], [260], [—],
      [Bolt, sinf 8.8], [M5 mahkamlaş boltlari], [210], [640], [800], [—],
      [Toblangan pölat], [Ø4 markazlaş ştiftlari], [210], [600], [—], [—],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Konstruksiya materiallarining mexanik xossalari],
) <tab-mat>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (auto, 1fr, 1fr),
      align: (left + horizon, left + horizon, left + horizon),
      stroke: none,
      inset: (x: 6pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header([*Yuklama holati*], [*Tavsifi*], [*Asosiy hisobiy kattaliklar*]),
      table.hline(stroke: 0.5pt),
      [YH-1: normal rejim],
      [tezlaniş $a = 5 "m/s"^2$, foydali yuk 5 kg],
      [$T_a = 0.132 "N" dot "m"$, $F_a approx 32 "N"$, \ karetka oğirligi $F = 62.3 "N"$],
      [YH-2: favqulodda],
      [karetka tirgakka tiralgan, dvigatel çöqqi momenti],
      [$T_max = 3 T_n = 1.91 "N" dot "m"$, \ $F_a$ --- (@eq-Fa) böyiça],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Hisobiy yuklama holatlari],
) <tab-loads>

= Amaliy maşğulotni bajariş tartibi

== 1-topşiriq: yuklama holatlarini aniqlaş

+ @tab-loads dagi yuklama holatlari uçun hisobiy sxemalarni tuzing. Har bir elementga taʼsir qiluvçi kuç va momentlarni aniqlang (@fig-load).
+ (@eq-Fa) böyiça favqulodda holatdagi öq kuçini hisoblang. Kuçning vint, qattiq tayanç, korpus, boltlar va asos plitasi orqali uzatiliş yölini çizing.

== 2-topşiriq: analitik tekşiruv hisoblari

+ Şarik-vintli vintni murakkab kuçlanganlik (@eq-mises) va turğunlik (@eq-euler) böyiça tekşiring. Buning uçun @lst-vint dagi dasturdan foydalaning. Eyler formulasining qöllaniliş şartini (@eq-lambda) tekşiring.
+ Vintning dvigatel tomonidagi böynini (Ø8 mm, yelka galteli $K_t = 2.0$) normal rejimdagi özgaruvçi buraliş böyiça çarçoqqa tekşiring (@eq-fatigue).
+ Qattiq tayanç korpusini asos plitasiga mahkamlovçi 2 ta M5 boltni siljiş (@eq-slip), ağdariliş va mustahkamlik (@eq-bolt) böyiça tekşiring. Boltlar siljigan holat uçun Ø4 ştiftlarni kesiliş va eziliş böyiça tekşiring.
+ Asos plitasini ikki uçidan tayangan tösin deb qarab, karetka örtada turgan holat uçun egiliş kuçlanişi va salqilikni hisoblang (@eq-beam, @fig-beam). Salqilikni modulning takroriy pozitsiyalaş aniqligi ($plus.minus 0.01$ mm) bilan solişting.

#figure(
  ```python
  import math

  # Dastlabki maʼlumotlar (N, mm, MPa)
  T_max = 1.91e3              # dvigatel çöqqi momenti, N·mm
  p, eta = 10.0, 0.9          # vint qadami (mm) va FIK
  d_r, l_k, mu = 9.9, 340.0, 0.7
  E, R_e = 2.1e5, 420.0       # C55 pölat

  F_a = 2 * math.pi * eta * T_max / p          # öq kuçi, N
  A = math.pi * d_r**2 / 4                     # kesim yuzasi
  W_p = math.pi * d_r**3 / 16                  # qutb qarşilik momenti
  sigma, tau = F_a / A, T_max / W_p
  s_eq = math.sqrt(sigma**2 + 3 * tau**2)      # fon Mizes böyiça
  I = math.pi * d_r**4 / 64
  F_cr = math.pi**2 * E * I / (mu * l_k)**2    # Eyler kritik kuçi
  lam = mu * l_k / (d_r / 4)                   # egiluvçanlik

  print(f"F_a = {F_a:.0f} N, σ = {sigma:.2f} MPa, τ = {tau:.2f} MPa")
  print(f"σ_ekv = {s_eq:.1f} MPa, n_T = {R_e / s_eq:.1f}")
  print(f"F_cr = {F_cr:.0f} N, n_tğ = {F_cr / F_a:.1f}, λ = {lam:.0f}")
  ```,
  caption: [Şarik-vintli vintni mustahkamlik va turğunlik böyiça tekşiriş dasturi],
) <lst-vint>

Dastur natijasi:

```text
F_a = 1080 N, σ = 14.03 MPa, τ = 10.03 MPa
σ_ekv = 22.3 MPa, n_T = 18.8
F_cr = 17253 N, n_tğ = 16.0, λ = 96
```

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    let L = 11.0
    // Tösin
    rect((0, 0), (L, 0.45), fill: blue.lighten(88%), stroke: 1pt + dslate)
    // Tayançlar
    let support(x) = {
      line((x, 0), (x - 0.35, -0.6), (x + 0.35, -0.6), close: true, stroke: 1pt + dslate, fill: white)
      line((x - 0.55, -0.6), (x + 0.55, -0.6), stroke: 1pt + dslate)
      for j in range(0, 5) {
        let xx = x - 0.5 + j * 0.25
        line((xx, -0.6), (xx - 0.2, -0.85), stroke: 0.5pt + dslate)
      }
    }
    support(0)
    support(L)
    // Kuç
    line((L / 2, 1.9), (L / 2, 0.5), stroke: 1.4pt + red.darken(10%), mark: (end: ">", fill: red.darken(10%)))
    content((L / 2 + 0.1, 1.9), text(size: 8.5pt, fill: red.darken(20%))[$F = 62.3$ N (karetka + yuk)], anchor: "west")
    // Salqilik egri çiziği (kattalaştirilgan)
    let pts = range(0, 101).map(j => {
      let x = L * j / 100
      let xi = if x <= L / 2 { x / L } else { 1 - x / L }
      (x, -1.6 - 1.2 * (3 * xi - 4 * calc.pow(xi, 3)))
    })
    line((0, -1.6), (L, -1.6), stroke: (paint: luma(150), thickness: 0.5pt, dash: "dashed"))
    line(..pts, stroke: 1.4pt + pblue)
    line((L / 2, -1.6), (L / 2, -2.8), stroke: 0.7pt, mark: (start: ">", end: ">", fill: black, scale: 0.5))
    content((L / 2 + 0.1, -2.2), text(size: 8.5pt)[$f$], anchor: "west")
    content((7.4, -1.35), text(size: 8pt, fill: pblue)[elastik çiziq (kattalaştirilgan)], anchor: "west")
    // Ölçam
    line((0, 2.6), (L, 2.6), stroke: 0.8pt, mark: (start: ">", end: ">", fill: black, scale: 0.6))
    content((L / 2, 2.65), text(size: 8pt)[$L = 440$ mm], anchor: "south")
    line((0, 0.5), (0, 2.75), stroke: (thickness: 0.4pt, dash: "dashed"))
    line((L, 0.5), (L, 2.75), stroke: (thickness: 0.4pt, dash: "dashed"))
    // Kesim
    rect((12.6, -0.3), (15.4, 0.15), fill: blue.lighten(80%), stroke: 1pt + dslate)
    content((14.0, 0.25), text(size: 8pt)[kesim $b times t = 140 times 15$ mm], anchor: "south")
  }),
  caption: [Asos plitasining hisobiy sxemasi va elastik çiziği],
) <fig-beam>

== 3-topşiriq: CAD muhitida FEA bilan tahlil

+ *Asos plitasi.* Teşiklarsiz plitaning soddalaştirilgan modelida ikki çetki tayanç çiziği böyiça şarnirli mahkamlaşni va örtadagi karetka bloklari yuzalariga $F = 62.3$ N yuklamani bering. Element ölçamini 20, 10, 5 va 2.5 mm qilib tör yaqinlaşuvini tekşiring. Natijani (@eq-beam) bilan solişting (@tab-mesh).
+ *Qattiq tayanç korpusi.* Korpus tagini asos plitasiga mahkamlang, ştift teşiklarini siljişga qarşi çeklang va podşipnik taşqi halqasi tiraladigan yelkaga $F_a$ kuçni bering. Yelka galtelini ikki variantda modellang: $r = 0.5$ mm va ötkir burçak ($r = 0$). Har bir variant uçun element ölçamini 2, 1, 0.5 va 0.25 mm qilib, eng katta fon Mizes kuçlanişini yozib oling.
+ Kuçlaniş va zaxira koeffitsienti epyuralarini (_Factor of Safety plot_) quring. Eng xavfli nuqtalarni aniqlang.

== 4-topşiriq: natijalarni umumlaştiriş va konstruktiv takliflar

+ Barça tekşiruv natijalarini @tab-summary ga kiriting va zaxira koeffitsientlarini talab qilingan qiymatlar bilan solişting.
+ Talabga javob bermaydigan element uçun kamida ikkita konstruktiv yeçim taklif qiling. Ularning taʼsirini parametrik model orqali qayta hisoblang.

= Natijalar jadvallari

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: 4,
      align: center + horizon,
      stroke: none,
      inset: (x: 7pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        table.cell(colspan: 2)[*Asos plitasi*],
        table.cell(colspan: 2)[*Qattiq tayanç korpusi*],
        [*Element \ ölçami \[mm\]*], [*Salqilik \ $f$ \[µm\]*],
        [*Element \ ölçami \[mm\]*], [*$sigma_max$ \[MPa\]: \ $r = 0.5$ / $r = 0$*],
      ),
      table.hline(stroke: 0.5pt),
      [20], [37.2], [2], [12.4 / 13.1],
      [10], [39.4], [1], [16.9 / 19.8],
      [5], [40.0], [0.5], [18.4 / 27.6],
      [2.5], [40.2], [0.25], [18.9 / 38.9],
      table.hline(stroke: 0.5pt),
      [Analitik (@eq-beam)], [40.7], [Yaqinlaşgan qiymat], [$approx 19$ / yaqinlaşmaydi],
      table.hline(stroke: 1pt),
    )
  },
  caption: [FEA tör yaqinlaşuvini tekşiriş natijalari (namunaviy)],
) <tab-mesh>

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // x: element ölçami (2, 1, 0.5, 0.25 mm) — teng qadamli; y: 1 birlik = 5 MPa
    let xs = (1, 3, 5, 7)
    let r05 = (12.4, 16.9, 18.4, 18.9)
    let r0 = (13.1, 19.8, 27.6, 38.9)
    grid(
      (0, 0),
      (8, 8),
      step: 1,
      stroke: 0.3pt + luma(225),
    )
    line((0, 0), (8.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    content((8.6, 0), text(size: 9pt)[element ölçami \[mm\]], anchor: "west")
    line((0, 0), (0, 8.5), stroke: 1pt, mark: (end: ">", fill: black))
    content((0, 8.55), text(size: 9pt)[$sigma_max$ \[MPa\]], anchor: "south")
    for (j, lbl) in ("2", "1", "0.5", "0.25").enumerate() {
      content((xs.at(j), -0.1), text(size: 7.5pt)[#lbl], anchor: "north")
    }
    for j in range(0, 9, step: 2) {
      content((-0.1, j), text(size: 7.5pt)[#(j * 5)], anchor: "east")
    }
    line(..xs.zip(r05).map(((x, y)) => (x, y / 5)), stroke: 1.5pt + pblue)
    line(..xs.zip(r0).map(((x, y)) => (x, y / 5)), stroke: 1.5pt + red.darken(10%))
    for (x, y) in xs.zip(r05) { circle((x, y / 5), radius: 0.09, fill: pblue, stroke: none) }
    for (x, y) in xs.zip(r0) { circle((x, y / 5), radius: 0.09, fill: red.darken(10%), stroke: none) }
    content((7.2, 3.4), text(size: 8pt, fill: pblue)[$r = 0.5$ mm: yaqinlaşadi], anchor: "west")
    content((5.6, 7.6), text(size: 8pt, fill: red.darken(20%))[$r = 0$: singulyarlik], anchor: "east")
  }),
  caption: [Korpus yelkasidagi eng katta kuçlanişning element ölçamiga boğliqligi],
  placement: auto,
) <fig-conv>

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (1.2fr, 1.3fr, auto, auto, auto, auto),
      align: (left + horizon, left + horizon, center + horizon, center + horizon, center + horizon, center + horizon),
      stroke: none,
      inset: (x: 4pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header([*Element*], [*Mezon*], [*Hisobiy \ qiymat*], [*$n$*], [*$[n]$*], [*Xulosa*]),
      table.hline(stroke: 0.5pt),
      [Vint (YH-2)], [fon Mizes, oqiş böyiça], [22.3 MPa], [18.8], [2.0], [yaroqli],
      [Vint (YH-2)], [turğunlik (Eyler)], [1080 N], [16.0], [3.0], [yaroqli],
      [Vint böyni Ø8 (YH-1)], [çarçoq, buraliş], [$tau_a = 2.36$ MPa], [60], [1.5], [yaroqli],
      [Boltlar 2 × M5 (YH-2)], [siljiş], [1080 N], [1.39], [1.3], [yaroqli (çegarada)],
      [Boltlar 2 × M5 (YH-2)], [ajraliş / mustahkamlik], [376 MPa], [3.6 / 1.70], [1.5], [yaroqli],
      [Ştiftlar 2 × Ø4 (YH-2)], [kesiliş], [43.0 MPa], [8.0], [2.0], [yaroqli],
      [Korpus (YH-2, FEA)], [fon Mizes], [19 MPa], [12.6], [2.0], [yaroqli],
      [Asos plitasi (YH-1)], [mustahkamlik], [1.31 MPa], [183], [2.0], [yaroqli],
      [Asos plitasi (YH-1)], [bikrlik], [$f = 40.7$ µm], [0.25], [1.0], [*yaroqsiz*],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Mustahkamlik, bikrlik va turğunlik tekşiruvlari natijalari (bikrlik uçun $n = [f] \/ f$, $[f] = 10$ µm)],
) <tab-summary>

= Namunaviy hisob-kitoblar va tahlil

== Favqulodda holatdagi öq kuçi

Dvigatelning çöqqi momenti $T_max = 3 dot 0.64 approx 1.91 "N" dot "m"$. (@eq-Fa) ga köra:

$ F_a = (2 pi dot 0.9 dot 1.91) / 0.01 approx 1080 "N" $

Bu normal rejimdagi öq kuçidan ($approx 32$ N) 33 marta katta. Demak, mexatron modul elementlarining mustahkamligi aynan favqulodda holat böyiça hisoblanişi kerak. Amaliyotda bu yuklamani servodrayverda tok çegarasini örnatiş va dasturiy çegara holatlari orqali kamaytiriş mumkin. Lekin konstruksiya baribir eng noqulay holatga çidamli bölişi lozim.

== Vintning mustahkamligi va turğunligi

Vint rezbasining içki diametri $d_r = 9.9$ mm böyiça (@eq-st) ga köra:

$ sigma = 1080 / 76.98 approx 14.03 "MPa", quad tau = 1910 / 190.5 approx 10.03 "MPa" $

$ sigma_"ekv" = sqrt(14.03^2 + 3 dot 10.03^2) approx 22.3 "MPa", quad n_T = 420 / 22.3 approx 18.8 $

Turğunlik uçun ($I = pi dot 9.9^4 \/ 64 approx 471.5 "mm"^4$, qattiq tayanç va gayka orasidagi qism uçun $mu = 0.7$):

$
  F_"cr" = (pi^2 dot 2.1 times 10^5 dot 471.5) / (0.7 dot 340)^2 approx 17 thin 250 "N", quad n_"tğ" = 17 thin 250 / 1080 approx 16.0
$

Eyler formulasining qöllaniliş şarti: $lambda = 0.7 dot 340 \/ (9.9 \/ 4) approx 96$. C55 pölat uçun $lambda_"pr" = pi sqrt(2.1 times 10^5 \/ 350) approx 77$. $lambda > lambda_"pr"$ bölgani uçun formula töğri qöllanilgan.

== Vint böynining çarçoq mustahkamligi

Normal rejimda moment har bir siklda $plus.minus T_a = plus.minus 0.132 "N" dot "m"$ oraliğida özgaradi (tezlaniş va sekinlaniş). $K_t = 2.0$ va $q = 0.8$ uçun $K_f = 1 + 0.8 (2.0 - 1) = 1.8$. Kuçlaniş amplitudasi:

$ tau_a = 16 T_a / (pi d^3) = (16 dot 132) / (pi dot 8^3) approx 1.31 "MPa", quad K_f tau_a approx 2.36 "MPa" $

$k_s = 0.85$ (silliqlangan sirt) va $k_d = 0.95$ uçun $tau_(-1 D) = 0.85 dot 0.95 dot 175 approx 141 "MPa"$. (@eq-fatigue) ga köra $n_tau = 141 \/ 2.36 approx 60$.

== Tayanç korpusining boltli birikmasi

*Siljiş.* $F_v approx 5 "kN"$ (8-maşğulot, tortiş momenti 5 N·m), $mu_t = 0.15$, $z = 2$:

$ n_"silj" = (F_v mu_t z) / F_a = (5000 dot 0.15 dot 2) / 1080 approx 1.39 > K = 1.3 $

Şart bajariladi, lekin çegarada. Şu sababli 8-maşğulotdagi Ø4 ştiftlar zaxira element sifatida zarur.

*Ağdariliş.* Öq kuçi vint öqi balandligida ($h_o = 40$ mm) taʼsir qilib, $M = 1080 dot 40 = 43 thin 200 "N" dot "mm"$ ağdaruvçi moment hosil qiladi. Ağdariliş qirrasidan boltlargaça masofa 12.5 mm bölsa, ikki boltga qöşimça kuç $F_b = 43 thin 200 \/ (2 dot 12.5) = 1728$ N tuşadi. $Phi = 0.2$ uçun (@eq-bolt):

$ F_b (1 - Phi) = 1728 dot 0.8 approx 1382 "N" < F_v = 5000 "N", quad n_"ajr" approx 3.6 $

$ sigma_b = (5000 + 0.2 dot 1728) / 14.2 approx 376 "MPa", quad n_b = 640 / 376 approx 1.70 $

*Ştiftlar* (boltlar siljigan holat, bir kesimli, $z = 2$):

$ tau = F_a / (z pi d^2 \/ 4) = 1080 / (2 dot 12.57) approx 43.0 "MPa", quad n = (0.577 dot 600) / 43.0 approx 8.0 $

Alyuminiy korpus teşigining ezilişi ($l = 8$ mm): $sigma_"ez" = 1080 \/ (2 dot 4 dot 8) approx 16.9 "MPa" << 240 "MPa"$.

== Asos plitasining mustahkamligi va bikrligi

$I = 140 dot 15^3 \/ 12 = 39 thin 375 "mm"^4$, $W = 140 dot 15^2 \/ 6 = 5250 "mm"^3$. (@eq-beam) ga köra:

$
  sigma = (62.3 dot 440 \/ 4) / 5250 approx 1.31 "MPa", quad f = (62.3 dot 440^3) / (48 dot 69 thin 000 dot 39 thin 375) approx 0.0407 "mm"
$

Kuçlaniş oqiş çegarasidan 183 marta kiçik, lekin salqilik ($40.7$ µm) takroriy pozitsiyalaş aniqligidan ($10$ µm) qariyb 4 marta katta. Demak, bu konstruksiyada hal qiluvçi mezon --- bikrlik. FEA natijasi ($40.2$ µm, @tab-mesh) analitik qiymatdan 1.2 % ga kiçik. Bu farq plitaning keng ($b \/ t approx 9$) bölişi tufayli yuzaga keladigan plastinka effekti bilan izohlanadi.

*Konstruktiv takliflar:*
+ Plita qalinligini 25 mm ga oşiriş: $f prop t^(-3)$ bölgani uçun $f = 40.7 dot (15 \/ 25)^3 approx 8.8$ µm. Talab bajariladi, lekin plita massasi 67 % ga oşadi.
+ Modulni asos plitasining butun uzunligi böyiça qattiq ramaga (stanina) mahkamlaş. Bunda plita oraliqda egilmaydi va salqilik amalda nolga teng böladi. Bu yeçim mexatron modullarda eng köp qöllaniladi, çunki modul bikrligi tayanç konstruksiyasi bilan birgalikda taʼminlanadi.
+ Yaxlit plita örniga qovurğali yoki quvursimon alyuminiy profil işlatiş. Bunda $I$ ni massa oşmasdan bir neça barobar oşiriş mumkin.

== FEA natijalarining tahlili

Korpus yelkasida $r = 0.5$ mm galtel bölganda kuçlaniş $approx 19$ MPa ga yaqinlaşadi (oxirgi ikki tör orasidagi farq 2.7 %). Ötkir burçakda esa u tör maydalaşgan sari töxtovsiz oşadi (@fig-conv). Bu FEA dagi singulyarlik bölib, bunday natija asosida mustahkamlik haqida xulosa çiqarib bölmaydi. Amaliy xulosa: çizmada barça içki burçaklar uçun galtel radiusini körsatiş va FEA modelida ham uni saqlaş kerak.

= Nazorat savollari

+ Mustahkamlik, bikrlik, turğunlik va çarçoq mezonlari qanday farqlanadi? Nima uçun mexatron modullarda köpinça bikrlik hal qiluvçi böladi?
+ Favqulodda yuklama holati qanday aniqlanadi va u nima uçun konstruksiya uçun hisobiy holat hisoblanadi?
+ Fon Mizes ekvivalent kuçlanişi qanday hisoblanadi va qaysi materiallar uçun qöllaniladi?
+ Eyler formulasi qaysi şartda qöllaniladi? Uzunlikni keltiriş koeffitsienti $mu$ tayanç sxemasiga qanday boğliq?
+ Kuçlaniş konsentratsiyasi koeffitsientlari $K_t$ va $K_f$ qanday farqlanadi?
+ Boltli birikmada siljiş va ajraliş şartlari qanday tekşiriladi? Nima uçun boltga taşqi kuçning faqat bir qismi uzatiladi?
+ Markazlaş ştiftlari boltli birikmada qanday vazifani bajaradi?
+ Tösin salqiligini kamaytirişning eng samarali konstruktiv usullari qaysilar?
+ FEA da tör yaqinlaşuvi qanday tekşiriladi va singulyarlik nima?
+ FEA natijalarini analitik hisob bilan soliştirişning ahamiyati nimada?
