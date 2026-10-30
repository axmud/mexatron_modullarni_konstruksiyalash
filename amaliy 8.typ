// ============================================================
//  Mexatron modullarni konstruksiyalaş — Yiğmani CAD muhitida konstruksiyalaş — amaliy maşğulot — Typst versiyasi
//  Kompilyatsiya: typst compile amaliy_8.typ
// ============================================================

#import "@preview/cetz:0.4.2"

#let headingblue = rgb(20, 50, 120)

#set document(title: "Mexatron modul yiğmasini CAD muhitida konstruksiyalaş")
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2cm),
)
// ===== HOSHIYA =====
#let info = json("fan.json")
#let raqam = 8  // amaliyot raqami
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
  #text(size: 20pt, weight: "bold", fill: headingblue)[AMALIYOT MAŞĞULOTI №8]
  #v(0.4cm)
  #text(
    size: 14pt,
    weight: "bold",
  )[Mavzu: Mexatron modul yiğmasini CAD muhitida konstruksiyalaş]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Işning maqsadi

*Maşğulotning maqsadi:* mexatron modul yiğmasini "yuqoridan pastga" (_top-down_) usulida, skelet modeli asosida CAD muhitida konstruksiyalaşni örganiş. 7-amaliy maşğulotda yaratilgan çiziqli modulning qattiq tayanç yiğmasini misolida quyidagi könikmalarni hosil qiliş:
- yiğma kontekstida detallarni loyihalaş;
- standart podşipnik va mahkamlaş elementlarini tanlaş;
- yiğma ölçam zanjirini maksimum-minimum, ehtimollik va Monte-Karlo usullarida tahlil qiliş;
- kompensator yordamida aniqlikni taʼminlaş;
- joylaşuvlarni hisoblaş;
- yiğiş ketma-ketligini işlab çiqiş va yiğiş texnologikligini (DFA) baholaş;
- yiğma çizmasini rasmiylaştiriş.

= Dasturiy va texnik taʼminot

+ *CAD tizimi:* SolidWorks, Autodesk Inventor yoki KOMPAS-3D (yiğma, standart elementlar kutubxonasi, kesişiş tahlili, yoyilgan köriniş va yiğma çizmasi modullari bilan). Bepul muqobil sifatida FreeCAD (Assembly va TechDraw iş muhitlari) qöllanilişi mumkin.
+ *Standart elementlar kutubxonasi:* SolidWorks Toolbox, Inventor Content Center yoki işlab çiqaruvçilarning STEP kataloglari (podşipniklar, boltlar, gaykalar, ştiftlar).
+ *Python (NumPy):* ölçam zanjirini Monte-Karlo usulida modellaş uçun.
+ *Dastlabki maʼlumotlar:* 7-amaliy maşğulotda yaratilgan çiziqli modulning 3D modeli va global parametrlari.

= Yiğmani konstruksiyalaşning nazariy asoslari

== Yiğmani loyihalaş usullari va skelet modeli

"Pastdan yuqoriga" (_bottom-up_) usulida detallar alohida yaratiladi va söng yiğmaga joylaştiriladi. Bu usul standart komponentlardan tuzilgan oddiy yiğmalar uçun qulay. Lekin detallar orasidagi ölçamlar özaro boğlanmaganligi sababli bitta detal özgartirilganda qolganlarini qölda tuzatiş kerak böladi.

"Yuqoridan pastga" (_top-down_) usulida avval yiğmaning skelet modeli yaratiladi. Skelet modeli asosiy öqlar, tekisliklar va gabarit çiziqlardan iborat çizma-eskiz bölib, unda modulning kinematik sxemasi va asosiy ölçamlari mujassamlaşgan. Detallar şu skeletga taşqi havolalar (_external references_) orqali boğlanib, yiğma kontekstida loyihalanadi (@fig-skelet). Natijada vint öqi balandligi yoki yuriş masofasi kabi asosiy parametr özgarganda barça boğliq detallar avtomatik moslaşadi.

Taşqi havolalardan foydalanişda quyidagi qoidalarga amal qiliş kerak:
+ detallar bir-biriga emas, faqat skelet modeliga havola qilsin (havolalar "yulduz" sxemasida bölsin);
+ havolalarning aylanma zanjirlariga yöl qöymaslik kerak;
+ loyihalaş tugagaç, standart detallarning havolalarini uziş yoki qotiriş (_lock_) kerak.

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
    let ref(a, b) = line(a, b, stroke: (paint: pblue, thickness: 1pt, dash: "dashed"), mark: (end: ">", fill: pblue))

    blk((0, 0), 3.0, 1.6, yellow.lighten(80%))[*Global parametrlar* \ $L_s$, $h_o$, $b_r$, $L_v$]
    blk(
      (5.2, 0),
      3.8,
      2.4,
      blue.lighten(85%),
    )[*Skelet modeli* \ (layout eskiz) \ vint öqi, rels öqlari, \ tayanç tekisliklari, \ gabarit çiziqlar]
    arr((1.5, 0), (3.3, 0))

    let parts = ([Asos plitasi], [Qattiq tayanç korpusi], [Suzuvçi tayanç korpusi], [Motor flanesi], [Karetka plitasi])
    for (q, p) in parts.enumerate() {
      let y = 2.4 - q * 1.2
      blk((11.2, y), 3.4, 0.85, green.lighten(85%), p)
      ref((7.1, 0), (9.5, y))
    }
    content((8.3, 2.2), text(size: 7.5pt, fill: pblue)[taşqi havolalar], anchor: "south")

    blk((5.2, -3.3), 7, 1.0, orange.lighten(80%))[*Yiğma*: komponentlar skelet tekisliklariga boğlanadi]
    arr((5.2, -1.2), (5.2, -2.8))
    line((11.2, -2.8), (11.2, -3.3), (8.7, -3.3), stroke: 1pt + dslate, mark: (end: ">", fill: dslate))
  }),
  caption: [Yiğmani skelet modeli asosida "yuqoridan pastga" konstruksiyalaş sxemasi],
) <fig-skelet>

== Yiğma ölçam zanjirlari

Yiğmadagi detallar ölçamlari ketma-ket ulanib, yopiq ölçam zanjirini hosil qiladi. Zanjirning yiğiş natijasida hosil bölgan ölçami _yopuvçi boğin_ $A_Delta$ deyiladi (tirqiş, taranglik, öqlar orasidagi masofa va h.k.). Uning nominal va örtaça qiymatlari taşkil etuvçi boğinlar orqali ifodalanadi:

$ A_Delta = sum_(i = 1)^n xi_i A_i, quad E_(c, Delta) = sum_(i = 1)^n xi_i E_(c, i) $ <eq-chain>

bunda $xi_i$ --- uzatiş koeffitsienti: oşiruvçi boğinlar uçun $+1$, kamaytiruvçi boğinlar uçun $-1$; $E_(c, i)$ --- $i$-boğin dopusk maydoni örtasining nominalga nisbatan oğişi.

*Maksimum-minimum usuli* barça boğinlar bir vaqtda eng noqulay çegaraviy qiymatlarni olganda ham töliq özaro almaşinuvçanlikni kafolatlaydi:

$ T_Delta = sum_(i = 1)^n abs(xi_i) T_i $ <eq-wc>

*Ehtimollik usuli* (kvadratik yiğindi, RSS) boğinlar mustaqil va normal taqsimlangan ($T_i = 6 sigma_i$) deb hisoblaydi. U yaroqsiz yiğmalarning juda kiçik uluşiga (taxminan 0.27 %) yöl qöyib, ança kengroq dopusklar bilan işlaş imkonini beradi:

$ T_Delta = sqrt(sum_(i = 1)^n xi_i^2 T_i^2) $ <eq-rss>

Agar har ikki usul ham talab qilingan $T_Delta$ ni taʼminlamasa, *kompensatsiya usuli* qöllaniladi. Bunda zanjirga ölçami yiğiş paytida tanlanadigan maxsus boğin (qistirma, halqa) kiritiladi. Kompensatorlar töplamidagi poğonalar soni:

$ N >= (T_"wc" - T_Delta) / (T_Delta - T_k) + 1 $ <eq-shim>

bunda $T_"wc"$ --- (@eq-wc) böyiça hisoblangan dopusk, $T_k$ --- kompensator tayyorlaş dopuski. Pöğona qadami $c <= T_Delta - T_k$ bölişi kerak.

== Joylaşuvlar

Silindrik ulanişlarda teşik va val dopusk maydonlarining özaro joylaşuvi ulaniş xarakterini belgilaydi (ISO 286). Teşik uçun yuqori va pastki oğişlar $E S$, $E I$, val uçun esa $e s$, $e i$ deb belgilanadi. Unda:

$ S_max = E S - e i, quad S_min = E I - e s, quad N_max = e s - E I $ <eq-fit>

$S_min >= 0$ bölsa, joylaşuv oraliqli; $S_max < 0$ (yaʼni $N_min > 0$) bölsa, taranglikli; qolgan hollarda ötuvçi böladi. Podşipniklarda aylanuvçi halqa taranglik bilan, qözğalmas halqa esa kiçik oraliq bilan örnatiladi. Bunda podşipnik halqalarining dopusk maydonlari ISO 492 böyiça faqat nominalga nisbatan manfiy tomonda joylaşadi.

== Mahkamlaş elementlari

Rezbali birikmani tanlaşda boltning dastlabki taranglaş kuçi va tortiş momenti quyidagiça baholanadi:

$ F_v approx 0.7 thin R_(p 0.2) A_s, quad M_t approx K F_v d $ <eq-bolt>

bunda $R_(p 0.2)$ --- bolt materialining oqiş çegarasi, $A_s$ --- rezbaning hisobiy kesim yuzasi, $d$ --- rezbaning nominal diametri, $K approx 0.2$ --- işqalaniş koeffitsienti (moylanmagan rezba uçun). Alyuminiy korpusga burab kiritiladigan boltlarda rezbaning işçi uzunligi kamida $2 d$ bölişi kerak.

== Yiğiş texnologikligi (DFA)

Boothroyd--Dewhurst usulida yiğiş texnologikligi quyidagi indeks bilan baholanadi:

$ E_"DFA" = (3 N_min) / t_a $ <eq-dfa>

bunda $3 "s"$ --- bitta ideal detalning yiğiş vaqti, $t_a$ --- yiğmaning umumiy hisobiy yiğiş vaqti, $N_min$ --- nazariy zarur detallar soni. Detal nazariy zarur hisoblanadi, agar quyidagi şartlardan kamida bittasi bajarilsa:
+ u boşqa detallarga nisbatan harakatlanadi;
+ u boşqa materialdan bölişi şart;
+ yiğiş yoki ajratiş uçun u alohida bölişi kerak.

Mahkamlaş elementlari, qistirmalar va ulanuvçi detallar odatda bu şartlarga javob bermaydi va ularni kamaytiriş texnologiklikni oşiradi.

= Tadqiqot obʼyekti: qattiq tayanç yiğmasi

7-maşğulotdagi çiziqli modulda şarik-vintli uzatmaning dvigatel tomonidagi qattiq tayançi vintni öq böyiça ikki yönalişda mahkamlaydi. Şu sababli u modulning öq böyiça bikrligi va pozitsiyalaş aniqligini belgilovçi asosiy yiğmadir. Tayançda O-sxemada (_back-to-back_) juft qilib örnatilgan ikkita radial-tayanç şarikli podşipnik (7000 turi, $d times D times B = 10 times 26 times 8$ mm) işlatiladi. Podşipniklarning taşqi halqalari korpus yelkasi va qopqoq börtigi orasida qisiladi, içki halqalari esa vint böyni yelkasi va fiksatorli gayka orasida qisiladi (@fig-section).

Qopqoq taşqi halqalarni işonçli qisişi uçun qopqoq gardişi va korpus torets orasida kiçik tirqiş $s$ qolişi kerak. Agar tirqiş bölmasa ($s <= 0$), qopqoq korpusga tiralib qoladi va halqalar qisilmaydi. Tirqiş juda katta bölsa esa boltlar tortilganda qopqoq qiyşayadi. Konstruktiv talab: $s = 0.02 dots 0.14$ mm.

#figure(
  {
    cetz.canvas(length: 0.95cm, {
      import cetz.draw: *
      set-style(content: (padding: 2pt))
      // masştab: 1 birlik = 4 mm (tirqiş va qistirma körinarli bölişi uçun kattalaştirilgan)
      let hatch(x0, y0, x1, y1, st: 0.3) = {
        let c = y0 - x1
        while c < y1 - x0 {
          let xa = calc.max(x0, y0 - c)
          let xb = calc.min(x1, y1 - c)
          if xa < xb { line((xa, xa + c), (xb, xb + c), stroke: 0.4pt + dslate) }
          c += st
        }
      }
      let sg = 0.25 // tirqiş s (kattalaştirilgan)

      // Öq çiziği
      line((-3.8, 0), (8.6, 0), stroke: (paint: dslate, thickness: 0.5pt, dash: "dash-dotted"))

      // 3 — vint va uning böyni
      rect((-3.5, 0), (0, 1.5), fill: luma(225), stroke: 0.8pt + dslate)
      rect((0, 0), (8.2, 1.25), fill: luma(235), stroke: 0.8pt + dslate)

      // 1 — korpus (L-şakl, kesim)
      hatch(-1.5, 2.3, 0, 5.0)
      hatch(0, 3.25, 5.0, 5.0)
      line((-1.5, 2.3), (0, 2.3), (0, 3.25), (5.0, 3.25), (5.0, 5.0), (-1.5, 5.0), close: true, stroke: 1pt + dslate)

      // 2 — podşipniklar (O-sxema)
      for (q, x0) in (0.0, 2.0).enumerate() {
        rect((x0, 2.6), (x0 + 2, 3.25), fill: luma(205), stroke: 0.8pt + dslate)
        rect((x0, 1.25), (x0 + 2, 1.9), fill: luma(205), stroke: 0.8pt + dslate)
        circle((x0 + 1, 2.25), radius: 0.33, fill: white, stroke: 0.8pt + dslate)
        let sgn = if q == 0 { 1 } else { -1 }
        line((x0 + 1 - 0.45 * sgn, 1.75), (x0 + 1 + 0.45 * sgn, 2.75), stroke: 0.5pt + red.darken(10%))
      }

      // 4 — vtulka
      rect((4.0, 1.25), (6.7, 1.9), fill: luma(215), stroke: 0.8pt + dslate)
      // 5 — kompensator qistirma
      rect((4.0, 2.6), (4.25, 3.2), fill: orange.lighten(40%), stroke: 0.8pt + dslate)

      // 6 — qopqoq (börtiq + gardiş, kesim)
      hatch(4.25, 2.1, 5.0 + sg, 3.2, st: 0.25)
      hatch(5.0 + sg, 2.1, 6.0 + sg, 5.0, st: 0.25)
      line(
        (4.25, 2.1),
        (4.25, 3.2),
        (5.0 + sg, 3.2),
        (5.0 + sg, 5.0),
        (6.0 + sg, 5.0),
        (6.0 + sg, 2.1),
        close: true,
        stroke: 1pt + dslate,
      )
      // 7 — ziçlagiç
      rect((5.5, 1.9), (6.0, 2.1), fill: dslate, stroke: none)
      // 8 — fiksatorli gayka
      rect((6.7, 1.25), (7.6, 2.4), fill: luma(190), stroke: 0.8pt + dslate)
      // 9 — bolt M5
      rect((3.6, 4.05), (6.0 + sg, 4.55), fill: white, stroke: 0.6pt + dslate)
      rect((6.0 + sg, 3.9), (6.9, 4.7), fill: luma(200), stroke: 0.8pt + dslate)
      line((3.4, 4.3), (7.1, 4.3), stroke: (paint: dslate, thickness: 0.4pt, dash: "dash-dotted"))

      // Ölçam zanjiri
      for x in (0.0, 2.0, 4.0, 4.25, 5.0, 5.0 + sg) {
        line((x, 5.05), (x, 6.85), stroke: (paint: luma(120), thickness: 0.4pt, dash: "dashed"))
      }
      let dim(a, b, y, lbl) = {
        line((a, y), (b, y), stroke: 0.7pt, mark: (start: ">", end: ">", fill: black, scale: 0.5))
        content(((a + b) / 2, y + 0.02), text(size: 8pt, lbl), anchor: "south")
      }
      dim(0, 2.0, 5.7, $B_1$)
      dim(2.0, 4.0, 5.7, $B_2$)
      dim(4.25, 5.0 + sg, 5.7, $h$)
      line((4.0, 5.7), (4.25, 5.7), stroke: 0.7pt)
      content((3.95, 6.1), text(size: 8pt)[$k$], anchor: "south")
      line((4.12, 5.72), (4.0, 6.1), stroke: 0.4pt)
      dim(0, 5.0, 6.6, $A_1$)
      line((5.0, 6.6), (5.0 + sg, 6.6), stroke: 0.7pt)
      content((5.55, 6.45), text(size: 8.5pt, weight: "bold", fill: red.darken(20%))[$s$], anchor: "west")
      line((5.13, 6.62), (5.5, 6.55), stroke: 0.4pt)

      // Raqamli körsatkiçlar
      let num(c, k) = {
        circle(c, radius: 0.24, fill: white, stroke: 0.8pt + dslate)
        content(c, text(size: 7.5pt, weight: "bold")[#k])
      }
      let callout(p, c, k) = {
        line(p, (c.at(0), c.at(1) + 0.24), stroke: 0.5pt + dslate)
        num(c, k)
      }
      callout((-0.75, 3.8), (-1.6, -1.0), 1)
      callout((1.0, 2.0), (0.4, -1.0), 2)
      callout((-2.5, 0.75), (-2.9, -1.0), 3)
      callout((5.2, 1.5), (4.6, -1.0), 4)
      callout((4.12, 2.75), (2.5, -1.0), 5)
      callout((5.8, 3.6), (8.0, 2.9), 6)
      callout((5.75, 2.0), (5.8, -1.0), 7)
      callout((7.15, 1.6), (7.0, -1.0), 8)
      callout((6.6, 4.5), (8.0, 5.3), 9)
    })
    v(0.2cm)
    set text(size: 8.5pt)
    grid(
      columns: 3,
      column-gutter: 0.8cm,
      row-gutter: 0.35em,
      align: left,
      [1 --- korpus (AW-6061)], [4 --- vtulka], [7 --- ziçlagiç],
      [2 --- podşipniklar 7000 (2 ta)], [5 --- kompensator qistirma], [8 --- fiksatorli gayka M10×1],
      [3 --- şarik-vintli vint böyni], [6 --- qopqoq], [9 --- bolt M5 (2 ta)],
    )
  },
  caption: [Qattiq tayanç yiğmasining yarim kesimi va ölçam zanjiri (tirqiş va qistirma kattalaştirib körsatilgan)],
) <fig-section>

Tirqiş $s$ yopuvçi boğin bölgan ölçam zanjiri (@fig-section):

$ s = h + k + B_1 + B_2 - A_1 $ <eq-s>

Bunda $h$, $k$, $B_1$, $B_2$ --- oşiruvçi boğinlar ($xi = +1$), $A_1$ --- kamaytiruvçi boğin ($xi = -1$). Zanjir boğinlarining qiymatlari @tab-chain da keltirilgan. Dastlabki variantda kompensator yöq ($k = 0$).

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (auto, 1fr, auto, auto, auto, auto),
      align: (center + horizon, left + horizon, center + horizon, center + horizon, center + horizon, center + horizon),
      stroke: none,
      inset: (x: 5pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header([*Belgi*], [*Boğin*], [*Nominal \ \[mm\]*], [*Oğişlar \ \[mm\]*], [*$xi_i$*], [*$T_i$ \ \[mm\]*]),
      table.hline(stroke: 0.5pt),
      [$A_1$], [Korpus yelkasidan torets gaça çuqurlik], [20.00], [$plus.minus 0.05$], [$-1$], [0.10],
      [$B_1$, $B_2$], [Podşipnik eni (ISO 492, normal sinf)], [8.00], [$0 thin \/ -0.12$], [$+1$], [0.12],
      [$h$], [Qopqoq börtigining balandligi], [4.20], [$plus.minus 0.02$], [$+1$], [0.04],
      [$k$], [Kompensator qistirma (2-variantda)], [töplam], [$plus.minus 0.005$], [$+1$], [0.01],
      table.hline(stroke: 0.5pt),
      [$s$], [*Yopuvçi boğin --- tirqiş (talab)*], [—], [$0.02 dots 0.14$], [—], [*0.12*],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Qattiq tayanç yiğmasining ölçam zanjiri boğinlari],
) <tab-chain>

= Amaliy maşğulotni bajariş tartibi

== 1-topşiriq: skelet modelini yaratiş va detallarni kontekstda loyihalaş

+ 7-maşğulotdagi modul yiğmasini oçing va yiğmaga yangi skelet detali (SolidWorks: _Layout_ yoki boş detal, Inventor: _Skeletal Modeling_) qöşing. Unda vint öqi ($h_o = 40$ mm), rels öqlari ($b_r = 90$ mm), qattiq va suzuvçi tayançlarning örta tekisliklari hamda karetkaning çetki holatlarini çizing. Skeletni global parametrlarga boğlang.
+ Qattiq tayanç korpusini yiğma kontekstida yarating: korpusning teşik öqi skeletdagi vint öqiga, asos tekisligi esa asos plitasining yuqori sirtiga havola qilsin.
+ Havolalar tuzilmasini tekşiring (SolidWorks: _External References_, Inventor: _Relationships_). Barça havolalar faqat skeletga yönalganiga, aylanma havolalar yöqligiga işonç hosil qiling.
+ $h_o$ ni 40 mm dan 45 mm ga özgartiring va korpus, motor flanesi hamda suzuvçi tayanç avtomatik moslaşganini kuzating. Söng $h_o$ ni asl qiymatiga qaytaring.

== 2-topşiriq: qattiq tayanç yiğmasini konstruksiyalaş

+ Podyiğma sifatida qattiq tayanç yiğmasini yarating. Standart elementlar kutubxonasidan ikkita 7000 radial-tayanç podşipnikni, M10×1 fiksatorli gaykani va M5 boltlarni joylaştiring. Boltlarni "aqlli mahkamlaş" (_Smart Fasteners_) vositasi bilan teşiklarga avtomatik joylaştiring.
+ Qopqoq, vtulka va kompensator qistirmani kontekstda yarating. Qopqoq börtigining diametri korpus teşigiga, uning balandligi $h$ esa global parametrga boğlansin.
+ Kompensator qistirmani konfiguratsiyalar (variantlar) bilan yarating: $k = 0.10$; $0.20$; $0.30$ mm. Konfiguratsiyalar jadvali (_Design Table_ / _iPart_) orqali ularni boşqaring.
+ Yiğmaning yarim kesimini oling va komponentlar orasidagi tirqişlar hamda kesişişlarni (_Interference Detection_, _Clearance Verification_) tekşiring.
+ Ulaniş sirtlariga @tab-fits dagi joylaşuvlarni belgilang va ularni (@eq-fit) böyiça hisoblang.

== 3-topşiriq: ölçam zanjirini tahlil qiliş

+ @tab-chain maʼlumotlari böyiça tirqiş $s$ ning nominal va örtaça qiymatini (@eq-chain) böyiça hisoblang.
+ Dopuskni maksimum-minimum (@eq-wc) va ehtimollik (@eq-rss) usullarida hisoblang va konstruktiv talab bilan solişting.
+ @lst-mc dagi dastur yordamida Monte-Karlo modellaşni bajaring. Yaroqsiz yiğmalar uluşini aniqlang va taqsimot gistogrammasini quring (@fig-mc).
+ Kompensator usulini qöllang. (@eq-shim) böyiça qistirmalar töplamidagi poğonalar sonini, ularning qalinliklarini va tanlaş qoidasini aniqlang (@tab-shim).
+ Agar CAD tizimida dopusk tahlili moduli bölsa (masalan, SolidWorks TolAnalyst), natijalarni u bilan ham tekşiring.

#figure(
  ```python
  import numpy as np

  rng = np.random.default_rng(1)
  N = 100_000
  # Boğinlar: örtaça qiymat va dopusk; normal taqsimot, ±3σ = T/2
  A1 = rng.normal(20.00, 0.10 / 6, N)   # korpus teşigi çuqurligi
  B1 = rng.normal(7.94, 0.12 / 6, N)    # 1-podşipnik eni
  B2 = rng.normal(7.94, 0.12 / 6, N)    # 2-podşipnik eni
  h = rng.normal(4.20, 0.04 / 6, N)     # qopqoq börtigi balandligi

  s = h + B1 + B2 - A1                  # yopuvçi boğin (tirqiş), mm
  ok = (s >= 0.02) & (s <= 0.14)
  print(f"örtaça = {s.mean():.4f} mm, σ = {s.std():.4f} mm")
  print(f"talabga mos: {ok.mean() * 100:.1f} %")
  print(f"yaroqsiz:    {(~ok).mean() * 100:.1f} %")
  ```,
  caption: [Ölçam zanjirini Monte-Karlo usulida modellaş (kompensatorsiz variant)],
) <lst-mc>

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // x: 1 birlik = 0.02 mm (−0.10 dan 0.26 gaça); y: 1 birlik = 4000 ta yiğma
    let counts = (0, 3, 12, 112, 718, 2890, 7968, 15745, 22294, 22887, 15892, 7860, 2805, 672, 124, 18, 0, 0)
    let x0 = -0.10
    let fx(v) = (v - x0) / 0.02
    grid(
      (0, 0),
      (18, 6),
      step: 1,
      stroke: 0.3pt + luma(225),
    )
    for (j, c) in counts.enumerate() {
      let v = x0 + 0.02 * j
      let inside = v >= 0.0199 and v + 0.02 <= 0.1401
      rect(
        (j + 0.05, 0),
        (j + 0.95, c / 4000),
        fill: if inside { pblue.lighten(30%) } else { red.lighten(30%) },
        stroke: 0.4pt + dslate,
      )
    }
    line((0, 0), (18.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    content((18.6, 0), text(size: 9pt)[$s$ \[mm\]], anchor: "west")
    line((0, 0), (0, 6.5), stroke: 1pt, mark: (end: ">", fill: black))
    content((0, 6.55), text(size: 9pt)[Yiğmalar soni], anchor: "south")
    for j in range(0, 19, step: 3) {
      content((j, -0.1), text(size: 7.5pt)[#calc.round(x0 + 0.02 * j, digits: 2)], anchor: "north")
    }
    for j in range(0, 7) {
      content((-0.1, j), text(size: 7.5pt)[#(j * 4000)], anchor: "east")
    }
    for v in (0.02, 0.14) {
      line((fx(v), 0), (fx(v), 6.2), stroke: (paint: red.darken(20%), thickness: 1pt, dash: "dashed"))
    }
    content((fx(0.02) - 0.1, 6.2), text(size: 8pt, fill: red.darken(20%))[$s_min$], anchor: "east")
    content((fx(0.14) + 0.1, 6.2), text(size: 8pt, fill: red.darken(20%))[$s_max$], anchor: "west")
    content((14.2, 4.6), text(size: 8pt)[yaroqli: 92.6 %], anchor: "west")
    content((14.2, 3.9), text(size: 8pt, fill: red.darken(20%))[yaroqsiz: 7.4 %], anchor: "west")
  }),
  caption: [Kompensatorsiz variantda tirqiş $s$ ning Monte-Karlo taqsimoti ($10^5$ ta yiğma)],
) <fig-mc>

== 4-topşiriq: yiğiş ketma-ketligi, texnologiklik va hujjatlar

+ @fig-seq dagi yiğiş ketma-ketligi asosida tayanç yiğmasining yoyilgan körinişini (_Exploded View_) qadamlarga bölib yarating va yiğiş animatsiyasini tayyorlang.
+ @tab-dfa böyiça (@eq-dfa) indeksni hisoblang. Detallar sonini kamaytiriş böyiça kamida ikkita taklif bering va yaxşilangan variant uçun indeksni qayta hisoblang.
+ Qattiq tayanç yiğmasining yiğma çizmasini ESKD talablari (GOST 2.109) böyiça rasmiylaştiring. Çizmada quyidagilar bölsin:
  - yarim kesim va pozitsiya raqamlari;
  - gabarit, montaj va ulaniş ölçamlari;
  - joylaşuvlar;
  - texnik talablar: tirqiş $s$, kompensator tanlaş qoidasi, boltlarni tortiş momenti.
+ Spetsifikatsiyani (GOST 2.106) avtomatik yarating va yiğmani STEP formatida eksport qiling.

#figure(
  cetz.canvas(length: 0.85cm, {
    import cetz.draw: *

    // ---- sizes: change only these ----
    let H = 1.8 // box height (was 1.1)
    let g = 0.7 // horizontal gap (arrow room) between columns
    let g2 = 0.5 // gap between boxes 4 and 5
    let vgap = 1.3 // vertical gap between the top and bottom rows
    let fs = 7.5pt // text size
    // box widths
    let w1 = 4
    let w3 = 3.7
    let w4 = 3.3
    let w5 = 2.9
    let w6 = 4.2
    let w7 = 2.8

    // derived positions
    let yt = (H + vgap) / 2
    let yb = -yt
    let x1 = 0
    let x3 = x1 + w1 / 2 + g + w3 / 2
    let x4 = x3 + w3 / 2 + g + w4 / 2
    let x5 = x4 + w4 / 2 + g2 + w5 / 2
    let x6 = (x4 - w4 / 2 + x5 + w5 / 2) / 2 // centred under boxes 4 and 5
    let x7 = x5 + w5 / 2 + g + w7 / 2

    let blk(c, w, fill, body) = {
      rect(
        (c.at(0) - w / 2, c.at(1) - H / 2),
        (c.at(0) + w / 2, c.at(1) + H / 2),
        fill: fill,
        stroke: 1pt + dslate,
        radius: 0.1,
      )
      content(c, align(center, text(size: fs, body)))
    }
    let arr(..pts) = line(..pts, stroke: 1pt + dslate, mark: (end: ">", fill: dslate))

    blk((x1, yt), w1, luma(235))[*1.* Korpus \ (asos detal)]
    blk((x1, yb), w1, luma(235))[*2.* Podşipniklarni vint \ böyniga presslaş (O-sxema)]
    blk((x3, 0), w3, green.lighten(85%))[*3.* Vint va podşipniklarni \ korpusga kirgiziş]
    blk((x4, yt), w4, orange.lighten(80%))[*4.* $s_0$ ni ölçaş va \ kompensator tanlaş]
    blk((x5, yt), w5, orange.lighten(80%))[*5.* Qistirma, qopqoq, \ 2 × M5 (5 N·m)]
    blk((x6, yb), w6, blue.lighten(88%))[*6.* Vtulka va fiksatorli gayka \ (içki halqalarni qisiş)]
    blk((x7, 0), w7, red.lighten(85%))[*7.* Aylaniş momenti \ va öq tepişini \ tekşiriş]

    arr((x1 + w1 / 2, yt), (x3 - w3 / 2, H / 4)) // 1 → 3
    arr((x1 + w1 / 2, yb), (x3 - w3 / 2, -H / 4)) // 2 → 3
    arr((x3 + w3 / 2, H / 4), (x4 - w4 / 2, yt)) // 3 → 4
    arr((x3 + w3 / 2, -H / 4), (x6 - w6 / 2, yb)) // 3 → 6
    arr((x4 + w4 / 2, yt), (x5 - w5 / 2, yt)) // 4 → 5
    arr((x5 + w5 / 2, yt), (x7 - w7 / 2, H / 4)) // 5 → 7
    arr((x6 + w6 / 2, yb), (x7 - w7 / 2, -H / 4)) // 6 → 7
  }),
  caption: [Qattiq tayanç yiğmasining yiğiş ketma-ketligi grafi],
) <fig-seq>

= Natijalar jadvallari

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (1.3fr, auto, auto, auto, auto, 1fr),
      align: (left + horizon, center + horizon, center + horizon, center + horizon, center + horizon, left + horizon),
      stroke: none,
      inset: (x: 4pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*Ulaniş*],
        [*Joylaşuv*],
        [*Teşik \ $E S thin \/ thin E I$ \[µm\]*],
        [*Val \ $e s thin \/ thin e i$ \[µm\]*],
        [*$S_max thin \/ thin N_max$ \ \[µm\]*],
        [*Turi*],
      ),
      table.hline(stroke: 0.5pt),
      [Podşipnik içki halqasi ↔ vint böyni],
      [Ø10 #h(0.1em) L0/k5],
      [$0 \/ -8$],
      [$+7 \/ +1$],
      [$N_max = 15$, \ $N_min = 1$],
      [taranglikli (aylanuvçi halqa)],
      [Podşipnik taşqi halqasi ↔ korpus],
      [Ø26 #h(0.1em) H7/l0],
      [$+21 \/ 0$],
      [$0 \/ -9$],
      [$S_max = 30$, \ $S_min = 0$],
      [oraliqli (qözğalmas halqa)],
      [Qopqoq börtigi ↔ korpus teşigi],
      [Ø26 #h(0.1em) H7/g6],
      [$+21 \/ 0$],
      [$-7 \/ -20$],
      [$S_max = 41$, \ $S_min = 7$],
      [oraliqli (markazlaş)],
      [Korpus ↔ asos plitasi (ştift)],
      [Ø4 #h(0.1em) H7/m6],
      [$+12 \/ 0$],
      [$+12 \/ +4$],
      [$S_max = 8$, \ $N_max = 12$],
      [ötuvçi (fiksatsiya)],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Qattiq tayanç yiğmasidagi joylaşuvlar (ISO 286, ISO 492)],
) <tab-fits>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (auto, auto, auto, auto),
      align: center + horizon,
      stroke: none,
      inset: (x: 7pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*Ölçangan $s_0$ \ (qistirmasiz) \[mm\]*],
        [*Tanlanadigan \ qistirma $k$ \[mm\]*],
        [*Natijaviy tirqiş \ $s$ \[mm\]*],
        [*Monte-Karlo böyiça \ qöllaniş uluşi \[%\]*],
      ),
      table.hline(stroke: 0.5pt),
      [$0.03 dots 0.14$], [— (qistirmasiz)], [$0.03 dots 0.14$], [0.8],
      [$-0.07 dots 0.03$], [0.10], [$0.03 dots 0.13$], [71.7],
      [$-0.17 dots -0.07$], [0.20], [$0.03 dots 0.13$], [27.4],
      [$-0.24 dots -0.17$], [0.30], [$0.06 dots 0.13$], [$< 0.1$],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Kompensator qistirmalar töplami va tanlaş qoidasi ($h = 4.07 plus.minus 0.02$ mm)],
) <tab-shim>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (1fr, auto, auto, auto, auto),
      align: (left + horizon, center + horizon, center + horizon, center + horizon, center + horizon),
      stroke: none,
      inset: (x: 6pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header([*Detal*], [*Soni*], [*Nazariy \ zarurmi?*], [*$N_min$ ga \ hissasi*], [*Yiğiş \ vaqti \[s\]*]),
      table.hline(stroke: 0.5pt),
      [Korpus], [1], [ha (asos detal)], [1], [3.0],
      [Podşipnik 7000], [2], [ha (nisbiy harakat)], [2], [16.0],
      [Qopqoq], [1], [ha (yiğiş va ajratiş uçun)], [1], [4.5],
      [Ziçlagiç], [1], [ha (boşqa material)], [1], [5.5],
      [Kompensator qistirma], [1], [yöq], [0], [4.0],
      [Vtulka va fiksatorli gayka], [1 + 1], [yöq], [0], [8.0],
      [Bolt M5 (dastlabki variant)], [4], [yöq], [0], [26.0],
      table.hline(stroke: 0.5pt),
      [*Jami (dastlabki variant)*], [*12*], [], [*5*], [*67.0*],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Qattiq tayanç yiğmasining DFA tahlili (Boothroyd--Dewhurst usuli)],
) <tab-dfa>

= Namunaviy hisob-kitoblar va tahlil

== Ölçam zanjirining örtaça qiymati

Boğinlar dopusk maydonlari örtalarining oğişlari: $E_(c, A_1) = 0$, $E_(c, B) = -0.06$ mm, $E_(c, h) = 0$. (@eq-s) va (@eq-chain) ga köra tirqişning örtaça qiymati:

$ s_c = h_c + B_(1 c) + B_(2 c) - A_(1 c) = 4.20 + 7.94 + 7.94 - 20.00 = 0.08 "mm" $

Bu qiymat talab qilingan oraliqning ($0.02 dots 0.14$ mm) örtasiga mos keladi. Demak, börtiq balandligining nominali $h = 4.20$ mm töğri tanlangan. Eʼtibor bering: agar podşipnik eni dopuskining bir tomonlama joylaşuvi hisobga olinmasa ($B_c = 8.00$ deb olinsa), örtaça tirqiş $0.20$ mm deb xato baholanadi.

== Maksimum-minimum va ehtimollik usullari

(@eq-wc) ga köra:

$
  T_s = 0.10 + 0.12 + 0.12 + 0.04 = 0.38 "mm", \
  s = 0.08 plus.minus 0.19 = -0.11 dots 0.27 "mm"
$

(@eq-rss) ga köra:

$
  T_s = sqrt(0.10^2 + 0.12^2 + 0.12^2 + 0.04^2) = sqrt(0.0404) approx 0.201 "mm", \
  s = 0.08 plus.minus 0.10 = -0.02 dots 0.18 "mm"
$

Har ikki usulda ham hisoblangan dopusk talab qilingan $T_Delta = 0.12$ mm dan katta. Asosiy hissani podşipniklar eni qöşadi ($2 dot 0.12^2 = 0.0288$, yaʼni $0.0404$ ning 71 %i). Podşipnik standart buyum bölgani uçun uning dopuskini toraytirib bölmaydi. Korpus va qopqoq dopusklarini istalgança toraytirsak ham, $sqrt(2 dot 0.12^2) approx 0.17 "mm" > 0.12 "mm"$ bölib qoladi.

== Monte-Karlo modellaş natijasi

@lst-mc dagi dastur natijasi: $overline(s) = 0.0800$ mm, $sigma_s = 0.0334$ mm, talabga mos yiğmalar 92.6 %, yaroqsiz yiğmalar 7.4 % (@fig-mc). Analitik baholaş ham şu natijani beradi: $sigma_s = 0.201 \/ 6 approx 0.0335$ mm, çegaralar örtaça qiymatdan $0.06 \/ 0.0335 approx 1.79 sigma$ masofada joylaşgan. Bunda normal taqsimot böyiça yaroqsiz yiğmalar uluşi $2 (1 - Phi(1.79)) approx 7.3 %$ ga teng. Har 14 ta yiğmadan bittasini qayta işlaş seriyali işlab çiqariş uçun qabul qilib bölmaydi.

== Kompensator qistirmalar töplamini hisoblaş

(@eq-shim) ga köra ($T_k = 0.01$ mm):

$ N >= (0.38 - 0.12) / (0.12 - 0.01) + 1 = 3.36 quad => quad N = 4 $

Qadam $c = 0.10 "mm" <= 0.11 "mm"$ deb qabul qilinadi. Qistirmasiz holatda tirqiş heç qaçon $s_max$ dan oşmasligi uçun börtiq balandligi kamaytiriladi:

$
  s_(0, max) = h_max + B_(1, max) + B_(2, max) - A_(1, min) = (h + 0.02) + 16.00 - 19.95 <= 0.14 \
  => h = 4.07 "mm"
$

Unda qistirmasiz tirqiş $s_0 = -0.24 dots 0.14$ mm oraliğida böladi. Toplam tört poğonadan iborat: qistirmasiz, 0.10, 0.20 va 0.30 mm. Tanlaş qoidasi @tab-shim da keltirilgan. Yiğişda korpus çuqurligi çuqurlik ölçagiç bilan, juft podşipnik eni esa mikrometr bilan ölçanadi va $s_0$ hisoblanadi. Monte-Karlo modellaş barça yiğmalar talabga mos kelişini körsatdi. Bunda yiğmalarning 99 % idan ortiğida 0.10 yoki 0.20 mm li qistirma işlatiladi, 0.30 mm li qistirma esa juda kam (faqat çetki holatlarda) kerak böladi. Bu ombordagi zaxirani reja qiliş uçun muhim maʼlumotdir.

== Joylaşuvlarni hisoblaş

Podşipnik içki halqasi va vint böyni ulanişi (Ø10 L0/k5) uçun (@eq-fit) ga köra:

$ N_max = e s - E I = 7 - (-8) = 15 thin mu"m", quad N_min = e i - E S = 1 - 0 = 1 thin mu"m" $

Joylaşuv taranglikli, çunki yuklama ostida aylanuvçi içki halqa valda burilib ketmasligi kerak. Taşqi halqa va korpus ulanişi (Ø26 H7/l0) uçun $S_max = 21 - (-9) = 30 thin mu"m"$, $S_min = 0 - 0 = 0$, yaʼni oraliqli joylaşuv. U taşqi halqani yiğişda erkin kirgiziş imkonini beradi, öq böyiça mahkamlaş esa qopqoq orqali amalga oşiriladi.

== Boltlarni tekşiriş

M5 bolt (mustahkamlik sinfi 8.8, $R_(p 0.2) = 640 "MPa"$, $A_s = 14.2 "mm"^2$) uçun (@eq-bolt) ga köra:

$ F_v approx 0.7 dot 640 dot 14.2 approx 6.36 "kN", quad M_t approx 0.2 dot 6360 dot 0.005 approx 6.4 "N" dot "m" $

Alyuminiy korpus rezbasini himoya qiliş uçun tortiş momenti 5 N·m qilib belgilanadi. Bunda taranglaş kuçi taxminan $5 \/ (0.2 dot 0.005) = 5 "kN"$ böladi. Qopqoqqa taşqi halqalar orqali uzatiladigan eng katta öq kuçi tezlaniş va işqalaniş kuçlarining yiğindisiga teng (7-maşğulot maʼlumotlari):

$ F_a = m_k a + F_f = 6.35 dot 5 + 0.62 approx 32.4 "N" $

Bu kuç ikki bolt orasida taqsimlanadi va taranglaş kuçidan bir neça yuz marta kiçik. Demak, qopqoqni 4 ta emas, 2 ta bolt bilan mahkamlaş yetarli.

== Yiğiş texnologikligi indeksi

@tab-dfa böyiça dastlabki variant uçun (@eq-dfa) ga köra:

$ E_"DFA" = (3 dot 5) / 67.0 approx 0.224 = 22.4 % $

Boltlar soni 4 tadan 2 taga kamaytirilsa, yiğiş vaqti $67.0 - 13.0 = 54.0$ s böladi va indeks oşadi:

$ E_"DFA" = (3 dot 5) / 54.0 approx 0.278 = 27.8 % $

Keyingi taklif: ziçlagiçni qopqoq bilan bitta detal qilib tayyorlaş (ikki komponentli quyma), şuningdek vtulka va fiksatorli gayka örniga yelkali fiksatorli gaykadan foydalaniş. Har bir taklif yiğiş vaqtini qisqartirişi bilan birga, bajarilişi kerak bölgan funksiya (ziçlaş, içki halqalarni qisiş) saqlanib qolişini tekşiriş kerak.

= Nazorat savollari

+ "Pastdan yuqoriga" va "yuqoridan pastga" yiğma usullarining afzalliklari va kamçiliklari nimalardan iborat?
+ Skelet modeli nima va taşqi havolalar qanday qoidalar asosida tuzilişi kerak?
+ Ölçam zanjirining yopuvçi, oşiruvçi va kamaytiruvçi boğinlari qanday aniqlanadi?
+ Maksimum-minimum va ehtimollik usullari qanday farqlanadi? Qaysi holda ehtimollik usulini qöllaş xavfli?
+ Nima uçun podşipnik eni dopuskining bir tomonlama joylaşuvini hisobga olmaslik katta xatoga olib keladi?
+ Kompensator usulining mohiyati nimada? Qistirmalar soni va qadami qanday aniqlanadi?
+ Podşipnik halqalari uçun joylaşuv qanday tanlanadi? Nima uçun aylanuvçi halqa taranglik bilan örnatiladi?
+ Radial-tayanç podşipniklarni O-sxemada örnatişning X-sxemaga nisbatan afzalligi nimada?
+ DFA indeksi qanday hisoblanadi va detal "nazariy zarur" deb qaysi şartlarda hisoblanadi?
+ Yiğma çizmasida qanday ölçamlar va texnik talablar körsatilişi kerak?
