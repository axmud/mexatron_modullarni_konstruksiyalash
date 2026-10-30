// ============================================================
//  Mexatron modullarni konstruksiyalaş — 3D CAD modeli — amaliy maşğulot — Typst versiyasi
//  Kompilyatsiya: typst compile amaliy_7.typ
// ============================================================

#import "@preview/cetz:0.4.2"

#let headingblue = rgb(20, 50, 120)

#set document(title: "Mexatron modulning 3D CAD modelini yaratiş")
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2cm),
)
// ===== HOSHIYA =====
#let info = json("fan.json")
#let raqam = 7  // amaliyot raqami
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
  #text(size: 20pt, weight: "bold", fill: headingblue)[AMALIYOT MAŞĞULOTI №7]
  #v(0.4cm)
  #text(
    size: 14pt,
    weight: "bold",
  )[Mavzu: Mexatron modulning 3D CAD modelini yaratiş]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Işning maqsadi

*Maşğulotning maqsadi:* mexatron modulni kompyuterli loyihalaş (CAD) muhitida parametrik detallar, standart komponentlar va yiğmalar asosida loyihalaş jarayonini örganiş. Servoyuritmali çiziqli pozitsiyalaş modulining 3D modelini yaratiş. Modul şarik-vintli uzatma, profil relsli yönaltiruvçilar va servodvigateldan iborat. Detallar orasidagi boğlanişlar orqali modulning kinematik erkinlik darajalarini tekşiriş. CAD modelidan olingan massa-inersion xususiyatlar asosida yuritmaning tekşiruv hisobini bajariş hamda konstruktorlik hujjatlarini (çizmalar, spetsifikatsiya) şakllantiriş könikmalarini hosil qiliş.

= Dasturiy va texnik taʼminot

+ *CAD tizimi:* SolidWorks, Autodesk Inventor yoki KOMPAS-3D (parametrik qattiq jismli modellaş va yiğma modullari bilan). Bepul muqobil sifatida FreeCAD (Part Design va Assembly iş muhitlari) ham qöllanilişi mumkin.
+ *Python va CadQuery kutubxonasi:* detallarni dastur kodi orqali parametrik modellaş va STEP formatiga eksport qiliş uçun.
+ *Standart komponentlar kataloglari:* işlab çiqaruvçilarning STEP formatidagi 3D modellari (servodvigatel, şarik-vintli juftlik, profil relslar va karetkalar, mufta, podşipnik tayanç bloklari).
+ *Dastlabki maʼlumotlar:* 5- va 6-tajriba maşğulotlarida aniqlangan servoyuritma parametrlari hamda @tab-spec dagi texnik talablar.
+ *Kompyuter:* kamida 16 GB operativ xotira va OpenGL ni qöllab-quvvatlovçi grafik karta.

= Mexatron modulni CAD muhitida loyihalaşning nazariy asoslari

== Loyihalaş bosqiçlari va raqamli maket

Mexatron modulni loyihalaş tizimli muhandislikning V-modeli asosida olib boriladi. Talablar va funksional tuzilma aniqlangandan söng konstruktiv yeçim CAD muhitida detallaştiriladi. Natijada 3D model raqamli maket (_digital mock-up_) vazifasini bajaradi. U geometrik moslik, yiğiş imkoniyati, massa-inersion xususiyatlar va kinematikani fizik prototip yaratilmasdan avval tekşiriş imkonini beradi. Bundan taşqari, CAD modeli köp jismli dinamik simulyatsiya (MBS) va çekli elementlar tahlili (FEA) uçun boşlanğiç maʼlumot böladi. Loyihalaş jarayonining asosiy bosqiçlari @fig-flow da keltirilgan. Tahlil natijalari talablarga mos kelmasa, parametrlar özgartirilib, model qayta quriladi.

#figure(
  cetz.canvas(length: 0.95cm, {
    import cetz.draw: *
    let blk(c, w, h, fill, body) = {
      rect(
        (c.at(0) - w / 2, c.at(1) - h / 2),
        (c.at(0) + w / 2, c.at(1) + h / 2),
        fill: fill,
        stroke: 1pt + dslate,
        radius: 0.1,
      )
      content(c, align(center, text(size: 8pt, body)))
    }
    let arr(..pts) = line(..pts, stroke: 1pt + dslate, mark: (end: ">", fill: dslate))

    blk((0, 0), 3.4, 1.2, yellow.lighten(80%))[*Texnik talablar* \ (yuriş, yuk, tezlik, aniqlik)]
    blk((5, 0), 3.4, 1.2, green.lighten(85%))[*Konseptual sxema* \ (uzatma, tayanç, datçiklar)]
    blk((10, 0), 3.4, 1.2, blue.lighten(88%))[*Parametrik detallar* \ (eskiz, çeklovlar, amallar)]
    blk((10, -2.4), 3.4, 1.2, orange.lighten(80%))[*Yiğma va boğlanişlar* \ (standart komponentlar)]
    blk((5, -2.4), 3.4, 1.2, red.lighten(85%))[*Tahlil* \ (massa, kinematika, kesişiş)]
    blk((0, -2.4), 3.4, 1.2, purple.lighten(88%))[*Çizmalar va* \ *spetsifikatsiya*]

    arr((1.7, 0), (3.3, 0))
    arr((6.7, 0), (8.3, 0))
    arr((10, -0.6), (10, -1.8))
    arr((8.3, -2.4), (6.7, -2.4))
    arr((3.3, -2.4), (1.7, -2.4))
    line(
      (5, -3.0),
      (5, -3.7),
      (12.2, -3.7),
      (12.2, 0),
      (11.7, 0),
      stroke: (paint: red.darken(10%), thickness: 1pt, dash: "dashed"),
      mark: (end: ">", fill: red.darken(10%)),
    )
    content((8.6, -3.75), text(size: 7.5pt, fill: red.darken(20%))[parametrlarni özgartiriş], anchor: "north")
  }),
  caption: [Mexatron modulni CAD muhitida loyihalaş bosqiçlari],
) <fig-flow>

== Parametrik modellaş asoslari

Zamonaviy CAD tizimlarida detal konstruktiv elementlar (_features_) ketma-ketligi sifatida quriladi. Avval tekislikda eskiz çiziladi, söng unga geometrik çeklovlar (parallellik, perpendikulyarlik, koaksiallik, simmetriya, ustma-ust tuşiş) va ölçamli çeklovlar qöyiladi. Keyin hajmiy amallar bajariladi: siqib çiqariş (_extrude_), aylantiriş (_revolve_), teşik, faska, yumaloqlaş (_fillet_), massiv (_pattern_). Eskiz elementlarining erkinlik darajalari: nuqta --- 2, kesma --- 4, aylana --- 3. Eskiz töliq aniqlangan bölişi uçun quyidagi şart bajarilişi kerak:

$ W_"esk" = sum_i f_i - sum_j c_j = 0 $ <eq-sketch>

bunda $f_i$ --- $i$-element erkinlik darajalari soni, $c_j$ --- $j$-çeklov olib taşlaydigan erkinlik darajalari soni. Töliq aniqlanmagan eskiz ($W_"esk" > 0$) parametr özgartirilganda kutilmagan şaklga kelişi mumkin. Ortiqça aniqlangan eskiz ($W_"esk" < 0$) esa qayta qurişda xatolikka olib keladi.

Konstruktorning ğoyasi (_design intent_) ölçamlar özaro boğliqlik tenglamalari va global parametrlar orqali modelga kiritiladi. Masalan, vint uzunligi yuriş masofasidan avtomatik hisoblanişi kerak:

$ L_v = L_s + L_k + 2 Delta $ <eq-Lv>

bunda $L_s$ --- karetkaning işçi yuriş masofasi, $L_k$ --- karetka (gayka korpusi) uzunligi, $Delta$ --- çetki holatlardagi xavfsizlik oraliği. Bunday model $L_s$ özgartirilganda barça boğliq detallarni avtomatik qayta quradi.

== Yiğma modeli va boğlanişlar

Fazoda erkin qattiq jism 6 ta erkinlik darajasiga ega. Yiğmada komponentlar orasiga qöyilgan har bir boğlaniş (_mate_, _constraint_) maʼlum sondagi erkinlik darajalarini olib taşlaydi. Yiğmaning qolgan erkinlik darajalari soni:

$ W = 6 (n - 1) - sum_i r_i $ <eq-mob>

bunda $n$ --- qözğalmas asos bilan birga jismlar (qattiq guruhlar) soni, $r_i$ --- $i$-boğlaniş olib taşlaydigan erkinlik darajalari. Asosiy boğlaniş turlari: tekisliklarning ustma-ust tuşişi --- 3, silindrik sirtlarning koaksialligi --- 4, koaksiallik va tekislik birgalikda (aylanma şarnir) --- 5, vint boğlanişi (aylaniş va siljişni qadam orqali boğlaydi) --- 1, mahkamlaş --- 6.

Kinematik juftliklar nuqtai nazaridan Kutsbax--Gryubler formulasi qöllaniladi:

$ W = 6 (n - 1) - sum_i (6 - f_i) $ <eq-kutz>

bunda $f_i$ --- $i$-kinematik juftlikning erkinlik darajalari soni. Agar natija kutilgan haqiqiy harakatçanlikdan kiçik çiqsa, mexanizm ortiqça boğlangan (statik noaniq) bölib, uni yiğiş uçun yuqori aniqlikdagi tayyorlaş talab etiladi. Amaliyotda ortiqça boğlanişlar suzuvçi tayançlar, kompensatsiyalovçi muftalar va sozlaş elementlari yordamida bartaraf etiladi.

== Massa-inersion xususiyatlar va yuritmani tekşiriş

Detallarga material (ziçlik) berilgandan söng CAD tizimi har bir detal va yiğmaning massasi, massa markazi hamda inersiya tenzorini hisoblaydi. Bu maʼlumotlar servoyuritmani tanlaşda bevosita qöllaniladi. Şarik-vintli uzatmada dvigatel valiga keltirilgan umumiy inersiya momenti:

$ J_Sigma = J_m + J_c + J_v + m_k (p / (2 pi))^2, quad J_v = (pi rho L_v d^4) / 32 $ <eq-Jsum>

bunda $J_m$ --- dvigatel rotori, $J_c$ --- mufta, $J_v$ --- vintning inersiya momenti, $m_k$ --- karetka va foydali yukning umumiy massasi, $p$ --- vint qadami (m), $rho$ --- vint materialining zişligi, $d$ --- vint diametri. Yuklama va dvigatel inersiyalari nisbati:

$ lambda_J = (J_Sigma - J_m) / J_m $ <eq-lambda>

6-tajribada körsatilganidek, bu nisbat oşgan sari rezonans va antirezonans çastotalari bir-biridan uzoqlaşadi va servokonturni sozlaş qiyinlaşadi. Tezlanişdagi zarur moment va dvigatelning aylaniş çastotasi:

$ T_a = J_Sigma (2 pi a) / p + (F_f p) / (2 pi eta), quad n = (60 v) / p $ <eq-Ta>

bunda $a$ va $v$ --- karetkaning çiziqli tezlanişi va tezligi, $F_f = mu m_k g$ --- yönaltiruvçilardagi işqalaniş kuçi, $eta$ --- vint-gayka juftligining FIK.

== Şarik-vintli uzatmaning kritik aylaniş çastotasi

Vint aylanganda uning egilişdagi birinçi xususiy çastotasiga mos aylaniş çastotasida rezonans yuzaga keladi. Kritik çastota işlab çiqaruvçi kataloglarida keltiriladigan amaliy formula bilan baholanadi:

$ n_"cr" = lambda_2 d_r / l_b^2 dot 10^7 quad ["ayl/min"] $ <eq-ncr>

bunda $d_r$ --- vint rezbasining içki diametri (mm), $l_b$ --- tayançlar orasidagi masofa (mm), $lambda_2$ --- tayanç sxemasi koeffitsienti: qattiq--erkin 3.4; erkin tayanç--erkin tayanç 9.7; qattiq--suzuvçi 15.1; qattiq--qattiq 21.9. Bu koeffitsientlarga 0.8 xavfsizlik koeffitsienti allaqaçon kiritilgan. Demak, (@eq-ncr) nazariy xususiy çastotaning 80 % iga teng ruxsat etilgan aylaniş çastotasini beradi va uni yana 0.8 ga köpaytiriş kerak emas.

= Modulning tuzilişi va dastlabki maʼlumotlar

Loyihalanadigan çiziqli pozitsiyalaş modulining tuzilişi @fig-module da, texnik talablar esa @tab-spec da keltirilgan. Vint qattiq--suzuvçi sxemada örnatilgan: dvigatel tomonidagi tayançda ikkita radial-tayanç podşipnik vintni öq böyiça mahkamlaydi, qarama-qarşi uçidagi tayanç esa faqat radial yuklamani qabul qilib, issiqlikdan uzayişga imkon beradi.

#figure(
  {
    cetz.canvas(length: 0.9cm, {
      import cetz.draw: *
      set-style(content: (padding: 2pt))
      let num(c, k) = {
        circle(c, radius: 0.24, fill: white, stroke: 0.8pt + dslate)
        content(c, text(size: 7.5pt, weight: "bold")[#k])
      }
      let lead(from, to) = line(from, to, stroke: 0.5pt + dslate)

      // 10 — asos plitasi
      rect((0, -0.6), (15, 0), fill: luma(225), stroke: 1pt + dslate)
      // 7 — profil rels
      rect((4.6, 0), (13.2, 0.3), fill: luma(190), stroke: 0.8pt + dslate)
      // 2 — motor flanesi (L-kronşteyn)
      rect((2.4, 0), (2.8, 2.6), fill: blue.lighten(75%), stroke: 1pt + dslate)
      // 1 — servodvigatel
      rect((0.1, 0.5), (2.4, 2.3), fill: green.lighten(80%), stroke: 1pt + dslate, radius: 0.08)
      // 3 — mufta
      rect((2.8, 1.1), (3.5, 1.7), fill: orange.lighten(70%), stroke: 1pt + dslate)
      // 4 — qattiq tayanç
      rect((3.5, 0), (4.4, 2.2), fill: blue.lighten(88%), stroke: 1pt + dslate)
      // 5 — vint
      rect((4.4, 1.25), (13.6, 1.55), fill: luma(170), stroke: 0.8pt + dslate)
      for j in range(0, 46) {
        let x = 4.5 + j * 0.2
        line((x, 1.25), (x + 0.1, 1.55), stroke: 0.4pt + dslate)
      }
      // 8 — suzuvçi tayanç
      rect((13.6, 0), (14.4, 2.2), fill: blue.lighten(88%), stroke: 1pt + dslate)
      // 6 — karetka: bloklar, gayka korpusi, plita
      rect((6.8, 0.3), (7.8, 0.9), fill: purple.lighten(80%), stroke: 0.8pt + dslate)
      rect((8.8, 0.3), (9.8, 0.9), fill: purple.lighten(80%), stroke: 0.8pt + dslate)
      rect((7.7, 0.95), (8.9, 2.3), fill: purple.lighten(65%), stroke: 0.8pt + dslate)
      rect((6.6, 2.3), (10.0, 2.7), fill: purple.lighten(85%), stroke: 1pt + dslate)
      // 9 — çegara datçiklari
      rect((5.0, 0), (5.4, 0.45), fill: red.lighten(60%), stroke: 0.8pt + dslate)
      rect((12.4, 0), (12.8, 0.45), fill: red.lighten(60%), stroke: 0.8pt + dslate)

      // Öq çiziği
      line((-0.3, 1.4), (15.0, 1.4), stroke: (paint: dslate, thickness: 0.5pt, dash: "dash-dotted"))

      // Ölçamlar
      line((6.6, 3.3), (11.6, 3.3), stroke: 0.8pt, mark: (start: ">", end: ">", fill: black, scale: 0.6))
      line((6.6, 2.75), (6.6, 3.45), stroke: 0.4pt)
      line((11.6, 2.75), (11.6, 3.45), stroke: (thickness: 0.4pt, dash: "dashed"))
      content((9.1, 3.35), text(size: 8pt)[$L_s = 300 "mm"$], anchor: "south")
      line((15.4, 0), (15.4, 1.4), stroke: 0.8pt, mark: (start: ">", end: ">", fill: black, scale: 0.6))
      content((15.45, 0.7), text(size: 8pt)[$h_o$], anchor: "west")

      // Raqamli körsatkiçlar
      lead((1.25, 2.3), (1.25, 3.0))
      num((1.25, 3.25), 1)
      lead((2.6, 2.6), (2.6, 3.0))
      num((2.6, 3.25), 2)
      lead((3.15, 1.7), (3.6, 3.0))
      num((3.75, 3.25), 3)
      lead((3.95, 2.2), (4.6, 3.0))
      num((4.85, 3.25), 4)
      lead((11.0, 1.55), (11.6, 2.4))
      num((11.75, 2.6), 5)
      lead((6.8, 2.7), (6.1, 3.05))
      num((5.95, 3.25), 6)
      lead((10.5, 0.15), (10.8, -1.1))
      num((10.8, -1.35), 7)
      lead((14.0, 2.2), (14.0, 2.95))
      num((14.0, 3.2), 8)
      lead((5.2, 0.2), (5.2, -1.1))
      num((5.2, -1.35), 9)
      lead((1.5, -0.3), (1.5, -1.1))
      num((1.5, -1.35), 10)
    })
    v(0.2cm)
    set text(size: 8.5pt)
    grid(
      columns: 2,
      column-gutter: 1cm,
      row-gutter: 0.35em,
      align: left,
      [1 --- servodvigatel], [6 --- karetka (plita, gayka korpusi, 4 ta blok)],
      [2 --- motor flanesi (kronşteyn)], [7 --- profil rels (2 ta)],
      [3 --- elastik mufta], [8 --- suzuvçi tayanç],
      [4 --- qattiq tayanç (2 ta podşipnik)], [9 --- çegara datçiklari],
      [5 --- şarik-vintli juftlik], [10 --- asos plitasi],
    )
  },
  caption: [Servoyuritmali çiziqli pozitsiyalaş modulining tuzilişi (yon köriniş)],
) <fig-module>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (auto, 1fr),
      align: (left + horizon, left + horizon),
      stroke: none,
      inset: (x: 6pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header([*Parametr*], [*Qiymati*]),
      table.hline(stroke: 0.5pt),
      [Işçi yuriş $L_s$], [300 mm],
      [Foydali yuk massasi $m_y$], [5 kg],
      [Maksimal tezlik $v_max$ / tezlaniş $a_max$], [0.5 m/s / 5 m/s²],
      [Takroriy pozitsiyalaş aniqligi], [$plus.minus 0.01$ mm],
      [Uzatma], [şarik-vintli juftlik, $d = 12$ mm, qadam $p = 10$ mm, $d_r approx 9.9$ mm],
      [Tayanç sxemasi], [qattiq--suzuvçi, tayançlar orasi $l_b approx 360$ mm],
      [Yönaltiruvçilar], [2 ta profil rels (15 mm), 4 ta karetka bloki],
      [Servodvigatel],
      [AC servo, 200 W, 60 mm flanes, 3000 ayl/min, \ $T_n = 0.64 "N" dot "m"$, $J_m = 1.8 times 10^(-5) "kg" dot "m"^2$],
      [Mufta], [elastik, $J_c = 1.2 times 10^(-6) "kg" dot "m"^2$],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Çiziqli pozitsiyalaş modulining texnik talablari va asosiy komponentlari],
) <tab-spec>

= Amaliy maşğulotni bajariş tartibi

== 1-topşiriq: global parametrlar va parametrik detallarni yaratiş

+ CAD tizimida yangi loyiha oçing va @tab-param dagi global parametrlarni (SolidWorks: _Global Variables_, Inventor: _Parameters_, FreeCAD: _Spreadsheet_) kiriting. Boğliq ölçamlarni (@eq-Lv) kabi tenglamalar orqali boğlang.
+ Asos plitasi, motor flanesi, karetka plitasi va tayanç korpuslarining detallarini yarating. Har bir eskiz töliq aniqlangan bölişini (@eq-sketch) şart va CAD tizimidagi "töliq aniqlangan" belgisi orqali tekşiring.
+ Montaj teşiklarini standart teşiklar ustasi (_Hole Wizard_) orqali yarating: M5 va M6 rezbali teşiklar, servodvigatel markazlaş teşigi Ø50H7.
+ Model parametrikligini tekşiring: $L_s$ ni 300 mm dan 400 mm ga özgartiring va asos plitasi, vint hamda rels uzunliklari avtomatik özgarganini kuzating.
+ Motor flanesini @lst-flange dagi CadQuery dasturi orqali ham yarating, STEP formatida eksport qiling va CAD tizimiga import qilib, qölda yaratilgan model bilan solişting.

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (auto, auto, auto, 1fr),
      align: (left + horizon, center + horizon, center + horizon, left + horizon),
      stroke: none,
      inset: (x: 5pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header([*Parametr*], [*Belgisi*], [*Qiymati*], [*Boğliqlik / izoh*]),
      table.hline(stroke: 0.5pt),
      [Işçi yuriş], [$L_s$], [300 mm], [boşqaruvçi parametr],
      [Karetka uzunligi], [$L_k$], [80 mm], [gayka korpusi böyiça],
      [Xavfsizlik oraliği], [$Delta$], [10 mm], [har bir çetki holatda],
      [Vint uzunligi], [$L_v$], [400 mm], [$L_s + L_k + 2 Delta$],
      [Asos plitasi uzunligi], [$L_a$], [460 mm], [$L_v + 60$ (motor va flanes)],
      [Asos plitasi eni / qalinligi], [$B_a$ / $t_a$], [140 / 15 mm], [AW-6061 alyuminiy qotişmasi],
      [Relslar orasidagi masofa], [$b_r$], [90 mm], [vint öqiga nisbatan simmetrik],
      [Öq balandligi], [$h_o$], [40 mm], [asos plitasi sirtidan],
      [Karetka plitasi], [—], [120 × 100 × 12 mm], [AW-6061],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Modelning global parametrlari va ularning özaro boğliqligi],
) <tab-param>

#figure(
  ```python
  import cadquery as cq

  # Parametrlar (mm) — barça ölçamlar şu yerda özgartiriladi
  W, H, T = 80.0, 80.0, 12.0   # plita ölçamlari
  PILOT_D = 50.0               # servodvigatel markazlaş börtigi uçun teşik
  PCD = 70.0                   # motor bolt teşiklari aylanasi diametri
  BOLT_D = 5.5                 # M5 boltlar uçun teşik
  MOUNT_D = 6.6                # M6 boltlar uçun (asosga mahkamlaş)
  FILLET_R = 4.0               # taşqi qirralar radiusi

  a = PCD / 2**0.5             # 45° dagi teşiklar kvadrati tomoni

  flange = (
      cq.Workplane("XY")
      .box(W, H, T)
      .edges("|Z").fillet(FILLET_R)
      .faces(">Z").workplane()
      .hole(PILOT_D)
      .faces(">Z").workplane()
      .rect(a, a, forConstruction=True).vertices()
      .hole(BOLT_D)
      .faces(">Z").workplane()
      .rect(W - 14, H - 14, forConstruction=True).vertices()
      .hole(MOUNT_D)
  )

  vol = cq.Shape.computeMass(flange.val())     # hajm, mm³
  print(f"Hajm: {vol:.0f} mm³, massa: {vol * 2.70e-6:.3f} kg (AW-6061)")
  cq.exporters.export(flange, "motor_flanes.step")
  ```,
  caption: [Motor flanesining CadQuery yordamidagi parametrik modeli],
  placement: auto,
) <lst-flange>

Dastur bajarilganda hajm $approx 50 thin 291 "mm"^3$ va massa $approx 0.136 "kg"$ çiqadi. Şu qiymatlar CAD tizimining massa xususiyatlari oynasidagi natija bilan mos kelişi kerak.

== 2-topşiriq: standart komponentlarni import qiliş va tayyorlaş

+ Servodvigatel, şarik-vintli juftlik, profil relslar va bloklar, mufta hamda podşipnik tayanç bloklarining STEP modellarini işlab çiqaruvçi kataloglaridan yuklab oling.
+ Modellarni soddalaştiring (_defeaturing_): mayda yozuvlar, rezba geometriyasi va içki detallarni olib taşlang, lekin ulaniş sirtlari va gabarit ölçamlarni saqlang. Bu yiğmaning tez işlaşini taʼminlaydi.
+ Har bir komponentga material va massani katalog qiymatlari böyiça bering. Masalan, karetka bloklarining massasi katalogdagi qiymatga moslaştiriladi.
+ Komponentlarni loyiha kutubxonasiga yagona nomlaş qoidasi böyiça saqlang (masalan, `MMK07-05-vint.step`).

== 3-topşiriq: yiğma modelini quriş va kinematikani tekşiriş

+ Yiğmani "pastdan yuqoriga" (_bottom-up_) usulida @fig-tree dagi tuzilma böyiça quring. Avval asos plitasini qözğalmas qilib mahkamlang.
+ Komponentlar orasiga @tab-mates dagi boğlanişlarni qöying. Yiğmaning qolgan erkinlik darajalari soni (@eq-mob) böyiça $W = 1$ bölişini tekşiring.
+ Vint boğlanişida qadamni $p = 10$ mm deb kiriting. Harakat tadqiqoti (_Motion Study_) yordamida dvigatel valiga 30 ayl berib, karetka 300 mm ga siljiganini tekşiring.
+ Butun yuriş davomida komponentlarning kesişişini (_Interference Detection_) va karetkaning çegara datçiklariga nisbatan holatini tekşiring.

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    let blk(c, w, h, fill, body) = {
      rect(
        (c.at(0) - w / 2, c.at(1) - h / 2),
        (c.at(0) + w / 2, c.at(1) + h / 2),
        fill: fill,
        stroke: 1pt + dslate,
        radius: 0.08,
      )
      content(c, align(center, text(size: 7.5pt, body)))
    }
    blk((7.2, 3.0), 4.6, 0.9, blue.lighten(80%))[*MMK07-00 Çiziqli modul* (yuqori yiğma)]
    let xs = (1.6, 5.35, 9.05, 12.8)
    let tops = (
      [*01 Asos yiğmasi*],
      [*02 Yuritma yiğmasi*],
      [*03 Vint yiğmasi*],
      [*04 Karetka yiğmasi*],
    )
    let items = (
      [asos plitasi \ profil relslar (2) \ tayanç korpuslari (2) \ çegara datçiklari (2)],
      [servodvigatel \ motor flanesi \ elastik mufta \ mahkamlaş boltlari],
      [şarik-vintli vint \ podşipniklar (3) \ gayka, şayba \ vint gaykasi],
      [karetka plitasi \ bloklar (4) \ gayka korpusi \ mahkamlaş boltlari],
    )
    line((7.2, 2.55), (7.2, 2.1), stroke: 1pt + dslate)
    line((xs.at(0), 2.1), (xs.at(3), 2.1), stroke: 1pt + dslate)
    for q in range(0, 4) {
      let x = xs.at(q)
      line((x, 2.1), (x, 1.75), stroke: 1pt + dslate)
      blk((x, 1.35), 3.4, 0.8, green.lighten(85%), tops.at(q))
      line((x, 0.95), (x, 0.6), stroke: 0.8pt + dslate)
      blk((x, -0.55), 3.4, 2.3, lbg, items.at(q))
    }
  }),
  caption: [Çiziqli modul yiğmasining tuzilmaviy daraxti],
  placement: auto,
) <fig-tree>

== 4-topşiriq: tahlil va konstruktorlik hujjatlari

+ Yiğmaning massa xususiyatlari oynasidan harakatlanuvçi qismlarning massasini va vintning inersiya momentini aniqlang (@tab-mass).
+ (@eq-Jsum)--(@eq-ncr) formulalar böyiça keltirilgan inersiya, inersiyalar nisbati, zarur moment va kritik aylaniş çastotasini hisoblang. Natijalarni servodvigatel pasport qiymatlari bilan solişting (7-bölim).
+ Yiğma çizmasini (umumiy köriniş, kesimlar, gabarit va montaj ölçamlari) hamda asos plitasi va motor flanesining detal çizmalarini rasmiylaştiring. Ulaniş sirtlariga mos joylaşuvlar va dopusklarni körsating (masalan, markazlaş teşigi Ø50H7, podşipnik örinlari Ø28H7).
+ Spetsifikatsiyani (_Bill of Materials_) avtomatik yarating va yiğmani STEP formatida eksport qiling.

= Natijalar jadvallari

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (1.25fr, auto, auto, 1fr),
      align: (left + horizon, center + horizon, center + horizon, left + horizon),
      stroke: none,
      inset: (x: 5pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header([*Komponentlar juftligi*], [*Boğlaniş turi*], [*Olinadigan \ erk. darajalari*], [*Natija*]),
      table.hline(stroke: 0.5pt),
      [Qattiq guruh (asos, relslar, tayançlar, motor)], [mahkamlaş], [—], [qözğalmas asos ($n$ ga kiradi)],
      [Vint ↔ tayanç podşipniklari], [koaksial + tekislik], [5], [faqat öq atrofida aylaniş],
      [Karetka bloklari ↔ rels], [2 ta tekislik ustma-ust], [3 + 2], [faqat rels böyiça siljiş],
      [Gayka ↔ vint], [vint boğlanişi ($p = 10$ mm)], [1], [aylaniş va siljiş boğlanadi],
      table.hline(stroke: 0.5pt),
      table.cell(colspan: 2, align: right)[*Jami:*], [*11*], [$W = 6 dot 2 - 11 = 1$],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Yiğmadagi boğlanişlar va qolgan erkinlik darajalari],
) <tab-mates>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (auto, auto, auto, auto),
      align: (left + horizon, center + horizon, center + horizon, center + horizon),
      stroke: none,
      inset: (x: 6pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header([*Komponent*], [*Material*], [*Massa \ \[kg\]*], [*Inersiya momenti \ \[kg·m²\]*]),
      table.hline(stroke: 0.5pt),
      [Karetka plitasi], [AW-6061], [0.390], [—],
      [Karetka bloklari (4 ta)], [podşipnik pölati], [0.720], [—],
      [Gayka va gayka korpusi], [pölat / AW-6061], [0.240], [—],
      [*Harakatlanuvçi qism jami* $m_c$], [], [*1.350*], [—],
      [Vint ($d = 12$ mm, $L_v = 400$ mm)], [pölat], [0.355], [$6.39 times 10^(-6)$],
      [Motor flanesi], [AW-6061], [0.136], [—],
      [Asos plitasi], [AW-6061], [2.550], [—],
      table.hline(stroke: 1pt),
    )
  },
  caption: [CAD modelidan olingan massa-inersion xususiyatlar (namunaviy natijalar)],
) <tab-mass>

= Namunaviy hisob-kitoblar va tahlil

== Eskizning erkinlik darajalarini tekşiriş

Töğri törtburçak eskizi 4 ta kesmadan iborat: $sum f_i = 4 dot 4 = 16$. Çeklovlar: 4 ta uç nuqtalarning ustma-ust tuşişi ($4 dot 2 = 8$), 2 ta gorizontallik va 2 ta vertikallik ($4$), eni va böyi ölçamlari ($2$), bitta burçakni koordinata boşiga boğlaş ($2$). (@eq-sketch) ga köra:

$ W_"esk" = 16 - (8 + 4 + 2 + 2) = 0 $

Demak, eskiz töliq aniqlangan. Ölçamlardan biri olib taşlansa, $W_"esk" = 1$ bölib, eskiz şu yönalişda erkin özgarişi mumkin.

== Yiğmaning erkinlik darajalari va ortiqça boğlanişlar

@tab-mates böyiça $n = 3$ (qözğalmas asos, aylanuvçi vint, karetka) va $sum r_i = 11$. (@eq-mob) ga köra $W = 6 (3 - 1) - 11 = 1$. Bu modulning yagona boşqariladigan erkinlik darajasiga (dvigatel burçagi) mos keladi.

Endi şu mexanizmni kinematik juftliklar orqali ideal ravişda tavsiflaymiz: aylanma juftlik (vint--asos, $f = 1$), ilgarilanma juftlik (karetka--asos, $f = 1$) va vint juftligi (gayka--vint, $f = 1$). (@eq-kutz) ga köra:

$ W = 6 (3 - 1) - 3 (6 - 1) = 12 - 15 = -3 $

Manfiy natija mexanizmda uçta ortiqça boğlaniş borligini bildiradi: vint öqi, relslar yönalişi va gayka öqi bir-biriga ideal mos kelişi kerak. Haqiqiy konstruksiyada bu muammo suzuvçi tayanç (öq böyiça erkinlik), elastik mufta (öqlar noaniqligini kompensatsiyalaş) va rels hamda tayançlarni yiğişda sozlaş orqali hal qilinadi. CAD yiğmasida esa ortiqça boğlanişlar qöyilsa (masalan, gayka va vint orasiga qöşimça koaksiallik), tizim "ortiqça aniqlangan" xatoligini beradi.

== Dvigatel valiga keltirilgan inersiya

Vintning inersiya momenti ($rho = 7850 "kg/m"^3$):

$ J_v = (pi rho L_v d^4) / 32 = (pi dot 7850 dot 0.4 dot 0.012^4) / 32 approx 6.39 times 10^(-6) "kg" dot "m"^2 $

Harakatlanuvçi massa $m_k = m_c + m_y = 1.35 + 5.0 = 6.35 "kg"$. Uning dvigatel valiga keltirilgan inersiyasi:

$ m_k (p / (2 pi))^2 = 6.35 dot (0.01 / (2 pi))^2 approx 1.61 times 10^(-5) "kg" dot "m"^2 $

(@eq-Jsum) böyiça umumiy inersiya:

$ J_Sigma = (1.8 + 0.12 + 0.639 + 1.61) times 10^(-5) approx 4.17 times 10^(-5) "kg" dot "m"^2 $

(@eq-lambda) böyiça inersiyalar nisbati:

$ lambda_J = (4.17 - 1.8) / 1.8 approx 1.32 $

Bu qiymat servoyuritmalar uçun odatda tavsiya etiladigan çegaradan (5--10) ança kiçik. Demak, servokonturni yuqori ötkazuvçanlik bilan sozlaş mumkin.

== Zarur moment va aylaniş çastotasi

Burçak tezlaniş $alpha = 2 pi a \/ p = 2 pi dot 5 \/ 0.01 approx 3142 "rad/s"^2$. Yönaltiruvçilardagi işqalaniş kuçi ($mu = 0.01$, $eta = 0.9$): $F_f = 0.01 dot 6.35 dot 9.81 approx 0.62 "N"$. (@eq-Ta) ga köra:

$ T_a = 4.17 times 10^(-5) dot 3142 + (0.62 dot 0.01) / (2 pi dot 0.9) approx 0.131 + 0.001 = 0.132 "N" dot "m" $

$ n = (60 v_max) / p = (60 dot 0.5) / 0.01 = 3000 "ayl/min" $

Zarur çöqqi moment nominal momentning $0.132 \/ 0.64 approx 21 %$ ini taşkil etadi, aylaniş çastotasi esa nominal qiymatga teng. Demak, tanlangan 200 W li servodvigatel talablarni zaxira bilan qanoatlantiradi. Kerak bölsa, kiçikroq qadamli vint ($p = 5$ mm) bilan tezlik zaxirasini kamaytirib, moment zaxirasini oşiriş mumkin.

== Vintning kritik aylaniş çastotasi

Qattiq--suzuvçi sxema uçun $lambda_2 = 15.1$, $d_r = 9.9 "mm"$, $l_b = 360 "mm"$. (@eq-ncr) ga köra:

$ n_"cr" = 15.1 dot 9.9 / 360^2 dot 10^7 approx 11 thin 535 "ayl/min" $

Ruxsat etilgan çastota işçi çastotadan ($3000$ ayl/min) qariyb 3.8 marta katta. Yuriş masofasi oşirilganda $n_"cr"$ tayançlar orasining kvadratiga teskari proporsional kamayadi. Masalan, $l_b = 760 "mm"$ bölsa, $n_"cr" approx 2590$ ayl/min böladi. Bunda 0.5 m/s tezlikka erişib bölmaydi va kattaroq diametrli vint yoki qattiq--qattiq sxema talab etiladi. Parametrik model aynan şunday tekşiruvlarni tez bajariş imkonini beradi.

= Nazorat savollari

+ Mexatron modulni loyihalaşda 3D CAD modeli "raqamli maket" sifatida qanday vazifalarni bajaradi?
+ Eskizning töliq aniqlanganligi nima uçun muhim? Ortiqça aniqlangan eskiz qanday muammoga olib keladi?
+ Konstruktorning ğoyasi (_design intent_) global parametrlar va tenglamalar orqali qanday ifodalanadi?
+ Yiğmada koaksiallik, tekisliklarning ustma-ust tuşişi va vint boğlanişi neçtadan erkinlik darajasini olib taşlaydi?
+ "Pastdan yuqoriga" va "yuqoridan pastga" (_top-down_) yiğma usullarining farqi nimada?
+ Nima uçun Kutsbax--Gryubler formulasi çiziqli modul uçun manfiy natija beradi va bu konstruksiyada qanday hal qilinadi?
+ CAD modelidan olingan massa-inersion xususiyatlar servodvigatelni tanlaşda qanday qöllaniladi?
+ Inersiyalar nisbati $lambda_J$ servokonturning dinamikasiga qanday taʼsir qiladi (6-tajribaga boğlab tuşuntiring)?
+ Şarik-vintli uzatmaning kritik aylaniş çastotasi qaysi parametrlarga boğliq va uni qanday oşiriş mumkin?
+ Standart komponentlarning STEP modellarini soddalaştiriş nima uçun zarur?
