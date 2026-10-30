// ============================================================
//  Mexatron modullarni konstruksiyalaş — Texnik hujjatlar — amaliy maşğulot — Typst versiyasi
//  Kompilyatsiya: typst compile amaliy_12.typ
// ============================================================

#import "@preview/cetz:0.4.2"

#let headingblue = rgb(20, 50, 120)

#set document(title: "Yakuniy mexatron modulning texnik hujjatlarini işlab çiqiş")
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2cm),
)
// ===== HOSHIYA =====
#let info = json("fan.json")
#let raqam = 10  // amaliyot raqami
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
  #text(size: 20pt, weight: "bold", fill: headingblue)[AMALIYOT MAŞĞULOTI №12]
  #v(0.4cm)
  #text(
    size: 14pt,
    weight: "bold",
  )[Mavzu: Yakuniy mexatron modulning texnik hujjatlarini işlab çiqiş]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Işning maqsadi

*Maşğulotning maqsadi:* 4--11-maşğulotlarda tadqiq qilingan va loyihalangan çiziqli pozitsiyalaş modulining konstruktorlik va işlatiş hujjatlari majmuasini Konstruktorlik hujjatlarining yagona tizimi (ESKD) standartlari asosida işlab çiqiş. Bunda quyidagi könikmalar hosil qilinadi:
- loyihalaş bosqiçlari va hujjatlar töliqligini aniqlaş;
- buyum va hujjatlarni belgilaş tizimini qöllaş;
- texnik topşiriq tuziş;
- spetsifikatsiyani CAD maʼlumotlari asosida avtomatik şakllantiriş;
- yiğma va detal çizmalariga texnik talablar, dopusklar va sirt ğadir-budurligini yoziş;
- elektr prinsipial sxemasini tuziş;
- işlatiş qöllanmasi va sinov dasturini tayyorlaş;
- hujjatlarga özgariş kiritiş tartibini örganiş.

= Dasturiy va texnik taʼminot

+ *CAD tizimi:* SolidWorks, Autodesk Inventor yoki KOMPAS-3D (çizmalar, ESKD asosiy yozuv şablonlari, spetsifikatsiya moduli). Bepul muqobil sifatida FreeCAD (TechDraw iş muhiti) qöllanilişi mumkin.
+ *Elektr sxemalar tizimi:* EPLAN Electric P8, KOMPAS-Elektrik yoki bepul muqobil sifatida QElectroTech, KiCad.
+ *Mahsulot maʼlumotlarini boşqariş (PDM) tizimi* (ixtiyoriy): SolidWorks PDM yoki Autodesk Vault --- hujjat versiyalari va özgarişlarni boşqariş uçun.
+ *Python:* CAD dan eksport qilingan tarkib (BOM) asosida spetsifikatsiyani şakllantiriş uçun (@lst-spets).
+ *Meʼyoriy hujjatlar:* ESKD standartlari (GOST 2.xxx turkumi), ISO 286, ISO 2768, ISO 1101, ISO 21920 (sirt ğadir-budurligi), ISO 230-2.

= Texnik hujjatlarning nazariy asoslari

== Buyum turlari va loyihalaş bosqiçlari

GOST 2.101 böyiça buyumlar *detal* (yiğiş amallarisiz tayyorlanadigan buyum), *yiğma birlik* (tarkibiy qismlari yiğiş amallari bilan birlaştirilgan buyum), *kompleks* va *komplekt* turlariga bölinadi. Çiziqli modul --- yiğma birlik. Uning tarkibiga yiğma birliklar (yuritma, tayançlar, karetka), detallar, standart buyumlar va boşqa (sotib olinadigan) buyumlar kiradi.

Buyumni işlab çiqiş GOST 2.103 böyiça bosqiçlarga bölinadi (@fig-stages, @tab-stages). Har bir bosqiçda tegişli hujjatlar işlab çiqiladi va ularga *litera* beriladi. Litera hujjatlarning qaysi bosqiçga tegişli ekanini körsatadi.

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    let blk(c, w, h, fill, body) = {
      rect(
        (c.at(0) - w / 2, c.at(1) - h / 2),
        (c.at(0) + w / 2, c.at(1) + h / 2),
        fill: fill,
        stroke: 1pt + dslate,
        radius: 0.1,
      )
      content(c, align(center, text(size: 7.5pt, body)))
    }
    let arr(a, b) = line(a, b, stroke: 1pt + dslate, mark: (end: ">", fill: dslate))
    let xs = (0, 3.5, 7.0, 10.5, 14.0)
    let names = (
      [*Texnik topşiriq* \ GOST 15.016],
      [*Texnik taklif* \ litera П],
      [*Eskiz loyiha* \ litera Э],
      [*Texnik loyiha* \ litera Т],
      [*Işçi hujjatlar* \ litera О, О#sub[1], А],
    )
    let labs = (
      [talablar, \ sikl, aniqlik],
      [4--6-tajriba: \ tadqiqot],
      [7-maşğ.: \ 3D CAD],
      [8--11-maşğ.: yiğma, \ hisob, FEM, optim.],
      [12-maşğ.: \ hujjatlar majmuasi],
    )
    for (q, x) in xs.enumerate() {
      blk((x, 1.2), 3.0, 1.2, if q == 4 { orange.lighten(75%) } else { blue.lighten(88%) }, names.at(q))
      blk((x, -0.6), 3.0, 1.0, lbg, labs.at(q))
      line((x, 0.6), (x, -0.1), stroke: (paint: luma(130), thickness: 0.6pt, dash: "dashed"))
      if q < 4 { arr((x + 1.5, 1.2), (xs.at(q + 1) - 1.5, 1.2)) }
    }
  }),
  caption: [Loyihalaş bosqiçlari va ularning uşbu kurs maşğulotlari bilan boğliqligi],
) <fig-stages>

== Konstruktorlik hujjatlari turlari va töliqligi

GOST 2.102 böyiça hujjatlar *grafik* (çizmalar, sxemalar, elektron model) va *matnli* (spetsifikatsiya, tuşuntiriş xati, texnik şartlar, işlatiş hujjatlari) turlarga bölinadi. Asosiy konstruktorlik hujjati: detal uçun --- detal çizmasi, yiğma birlik uçun --- spetsifikatsiya. Har bir hujjat turi belgilaşga qöşiladigan kodga ega (@tab-docs). Elektron 3D model ham GOST 2.052 böyiça töla huquqli konstruktorlik hujjati hisoblanadi.

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (1.2fr, auto, auto, 1.6fr),
      align: (left + horizon, center + horizon, center + horizon, left + horizon),
      stroke: none,
      inset: (x: 5pt, y: 4.5pt),
      table.hline(stroke: 1pt),
      table.header([*Hujjat*], [*Kod*], [*Standart*], [*Çiziqli modul uçun mazmuni*]),
      table.hline(stroke: 0.5pt),
      [Spetsifikatsiya], [—], [GOST 2.106], [yuqori yiğma va har bir yiğma birlikning tarkibi],
      [Yiğma çizmasi], [СБ], [GOST 2.109], [yarim kesimlar, pozitsiyalar, ölçamlar, texnik talablar],
      [Detal çizmasi], [—], [GOST 2.109], [korpus, qopqoq, asos profili, flanes, tirgak],
      [Gabarit çizma], [ГЧ], [GOST 2.109], [gabarit, ulaniş va montaj ölçamlari, massa markazi],
      [Elektron model], [—], [GOST 2.052], [3D yiğma modeli (STEP)],
      [Elektr prinsipial sxemasi], [Э3], [GOST 2.701, 2.702], [taʼminot, servodrayver, dvigatel, datçiklar],
      [Tuşuntiriş xati], [ПЗ], [GOST 2.106], [tadqiqot va hisob-kitoblar (4--11-maşğ.)],
      [Texnik şartlar], [ТУ], [GOST 2.114], [texnik tavsiflar, qabul qiliş va sinov qoidalari],
      [Sinov dasturi va metodikasi], [ПМ], [GOST 2.106], [qabul sinovlari va ularning usullari],
      [Işlatiş qöllanmasi], [РЭ], [GOST 2.601, 2.610], [xavfsizlik, örnatiş, sozlaş, texnik xizmat],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Çiziqli modul uçun konstruktorlik va işlatiş hujjatlari majmuasi],
) <tab-docs>

== Belgilaş tizimi

GOST 2.201 böyiça buyum belgisi taşkilot kodi, klassifikatsion tavsif va tartib raqamidan iborat. Masalan, `ABVG.302215.001` yozuvida `ABVG` --- işlab çiquvçi taşkilot kodi, `302215` --- klassifikator böyiça buyum turi, `001` --- tartib raqami. Hujjat belgisi buyum belgisiga hujjat kodini qöşiş orqali hosil qilinadi: `ABVG.302215.001 СБ`.

Öquv loyihalarida köpinça tuzilmaviy (sxemaviy) belgilaş qöllaniladi. Bunda belgining raqamlari buyumning yiğma daraxtidagi örnini aks ettiradi (@fig-tree):

$
  underbrace("MMK", "loyiha") . underbrace("12", "buyum") . underbrace("02", "yiğma birlik") . underbrace("00", "podyiğma") . underbrace("004", "detal") - underbrace("01", "ijro")
$ <eq-design>

Bir xil vazifali, lekin ölçamlari farq qiladigan buyumlar (masalan, 8-maşğulotdagi turli qalinlikdagi kompensator qistirmalar) *ijrolar* sifatida bitta belgi ostida rasmiylaştiriladi: `-01`, `-02`, `-03`. Bu CAD tizimidagi konfiguratsiyalarga mos keladi.

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
      content(c, align(center, text(size: 7pt, body)))
    }
    blk((8.0, 4.4), 5.0, 0.9, blue.lighten(80%))[*MMK.12.00.00.000* \ Çiziqli pozitsiyalaş moduli]
    let xs = (1.6, 5.9, 10.1, 14.4)
    let subs = (
      [*MMK.12.01.00.000* \ Yuritma yiğmasi],
      [*MMK.12.02.00.000* \ Qattiq tayanç yiğmasi],
      [*MMK.12.03.00.000* \ Suzuvçi tayanç yiğmasi],
      [*MMK.12.04.00.000* \ Karetka yiğmasi],
    )
    line((8.0, 3.95), (8.0, 3.5), stroke: 1pt + dslate)
    line((xs.at(0), 3.5), (xs.at(3), 3.5), stroke: 1pt + dslate)
    for (q, x) in xs.enumerate() {
      line((x, 3.5), (x, 3.15), stroke: 1pt + dslate)
      blk((x, 2.75), 3.8, 0.8, if q == 1 { orange.lighten(75%) } else { green.lighten(85%) }, subs.at(q))
    }
    let parts = (
      [*.02.00.001* Korpus],
      [*.02.00.002* Qopqoq],
      [*.02.00.003* Vtulka],
      [*.02.00.004-01…-03* \ Kompensator qistirma \ (0.10 / 0.20 / 0.30 mm)],
    )
    let ys = (1.6, 0.9, 0.2, -0.85)
    line((4.3, 2.35), (4.3, ys.at(3)), stroke: 0.8pt + dslate)
    for (q, y) in ys.enumerate() {
      line((4.3, y), (4.7, y), stroke: 0.8pt + dslate)
      blk((6.6, y), 3.8, if q == 3 { 1.2 } else { 0.55 }, lbg, parts.at(q))
    }
    content(
      (9.0, 0.9),
      text(size: 7.5pt)[Standart buyumlar: \ podşipniklar 7000 (2), \ fiksatorli gayka M10×1, \ vint M5 (2)],
      anchor: "west",
    )
  }),
  caption: [Çiziqli modul tarkibiy qismlarining tuzilmaviy belgilaş daraxti (fragment)],
) <fig-tree>

== Çizmalarga qöyiladigan asosiy talablar

Çizmalar GOST 2.301--2.307 talablariga muvofiq bajariladi: formatlar (A4--A0), masştablar, çiziq turlari, şriftlar, körinişlar, kesim va qirqimlar, ölçam qöyiş. Har bir varaqda GOST 2.104 böyiça asosiy yozuv (@fig-title) böladi. Detal çizmasida detalni tayyorlaş va nazorat qiliş uçun zarur barça maʼlumotlar körsatilişi kerak:
- *ölçamlar va dopusklar:* aniq ulaniş sirtlari uçun joylaşuvlar (ISO 286), qolgan ölçamlar uçun umumiy dopusklar (masalan, ISO 2768-mK) texnik talablarda körsatiladi;
- *şakl va joylaşuv dopusklari* (ISO 1101): masalan, podşipnik teşigi öqiga nisbatan yelkaning perpendikulyarligi;
- *sirt ğadir-budurligi* ($R a$): podşipnik örinlari uçun $R a$ 0.8--1.6 µm, erkin sirtlar uçun $R a$ 3.2--6.3 µm;
- *material va qoplama:* masalan, AW-6061-T6, anodlaş.

Yiğma çizmasida esa pozitsiya raqamlari (spetsifikatsiyaga mos), gabarit, montaj, ulaniş va nazorat qilinadigan ölçamlar, joylaşuvlar hamda yiğiş va sozlaş böyiça texnik talablar beriladi.
#set text(font: "GOST type B")

#figure(
  {
    set text(size: 7.5pt)
    set par(justify: false)
    show table.cell: it => align(center + horizon, skew(ax: -15deg, it.body))
    table(
      columns: (1.3cm, 1.3cm, 1.7cm, 1.3cm, 1.0cm, 4.6cm, 0.9cm, 0.9cm, 1.1cm, 1.3cm),
      rows: 0.55cm,
      align: center + horizon,
      stroke: 0.6pt + dslate,
      inset: 2pt,
      table.cell(colspan: 5)[], table.cell(colspan: 5, rowspan: 2)[#text(size: 11pt, weight: "bold")[MMK.12.02.00.001]],
      [Özg.], [Varaq], [Hujjat №], [Imzo], [Sana],
      [Işl. çiq.], table.cell(colspan: 2)[Talaba F.I.Ş.], [], [],
      table.cell(colspan: 2, rowspan: 3)[#text(size: 10pt)[Korpus]], [Litera], [Massa], [Masştab],
      [Tekşirdi], table.cell(colspan: 2)[Öqituvçi F.I.Ş.], [], [],
      [О], [0.11], [1:1],
      [T. nazorat], table.cell(colspan: 2)[], [], [],
      table.cell(colspan: 2)[Varaq 1], [Varaqlar 1],
      [], table.cell(colspan: 2)[], [], [],
      table.cell(colspan: 2, rowspan: 2)[#text(size: 8pt)[AW-6061-T6]],
      table.cell(colspan: 3, rowspan: 2)[#text(size: 8pt)[OTM, kafedra, guruh]],
      [N. nazorat], table.cell(colspan: 2)[], [], [],
      [Tasdiqladi], table.cell(colspan: 2)[], [], [], table.cell(colspan: 5)[],
    )
  },
  caption: text(font: info.font)[Detal çizmasining asosiy yozuvi (GOST 2.104 böyiça soddalaştirilgan köriniş)],
) <fig-title>
#set text(font: info.font)
== Elektr sxemalar

Sxemalar GOST 2.701 böyiça turi (elektr --- Э, gidravlik --- Г, pnevmatik --- П, kinematik --- К) va xili (tuzilmaviy --- 1, funksional --- 2, prinsipial --- 3, ulanişlar --- 4, birikişlar --- 5, umumiy --- 6, joylaşuv --- 7) böyiça kodlanadi. Masalan, Э3 --- elektr prinsipial sxemasi. Sxemadagi elementlar GOST 2.710 böyiça harf-raqamli pozitsion belgilarga ega: A --- qurilma (servodrayver, kontroller), M --- dvigatel, BQ --- holat datçigi, SQ --- yöl (çegara) uzgiçi, YB --- elektromagnit tormoz, QF --- avtomatik uzgiç, G --- taʼminot manbai. Elementlar röyxati (_elementlar perečeni_) sxemaning birinçi varağida yoki alohida hujjatda beriladi.

== Matnli hujjatlar

- *Texnik topşiriq* (GOST 15.016) buyurtmaçi va işlab çiquvçi orasidagi asosiy hujjat bölib, buyumning vazifasi, texnik talablari, bosqiçlari va qabul qiliş tartibini belgilaydi.
- *Tuşuntiriş xati* (ПЗ) loyihaviy yeçimlarning asoslanişini, hisob-kitoblar va tadqiqot natijalarini öz içiga oladi.
- *Texnik şartlar* (ТУ) buyumni tayyorlaş, qabul qiliş va yetkazib beriş talablarini belgilaydi.
- *Sinov dasturi va metodikasi* (ПМ) har bir sinov uçun maqsad, usul, ölçaş vositalari va qabul mezonlarini aniqlaydi.
- *Işlatiş qöllanmasi* (РЭ) foydalanuvçi uçun möljallangan: xavfsizlik talablari, örnatiş, sozlaş, işlatiş va texnik xizmat tartibi.
- Mexatron modulning boşqaruv dasturi uçun alohida dasturiy hujjatlar ham işlab çiqilişi mumkin (ESPD, GOST 19 turkumi).

== Hujjatlarga özgariş kiritiş

Tasdiqlangan hujjatga özgariş GOST 2.503 böyiça *özgariş xabarnomasi* asosida kiritiladi. Xabarnomada özgariş sababi, "edi" va "böldi" holatlari, özgariş taʼsir qiladigan boşqa hujjatlar (masalan, spetsifikatsiya) va joriy etiş muddati körsatiladi. Hujjatning asosiy yozuvidagi "Özg." ustuniga özgariş tartib raqami yoziladi. Elektron hujjatlarda bu jarayon PDM tizimidagi versiyalar va tasdiqlaş marşrutlari orqali amalga oşiriladi.

= Yakuniy modulning asosiy tavsiflari

Hujjatlar 4--11-maşğulotlar natijalariga asoslanadi. Yakuniy konstruksiyaning asosiy tavsiflari @tab-final da jamlangan.

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (auto, auto, 1fr),
      align: (left + horizon, left + horizon, left + horizon),
      stroke: none,
      inset: (x: 5pt, y: 4.5pt),
      table.hline(stroke: 1pt),
      table.header([*Tavsif*], [*Qiymati*], [*Asos (maşğulot)*]),
      table.hline(stroke: 0.5pt),
      [Işçi yuriş / foydali yuk], [300 mm / 5 kg], [texnik topşiriq (7)],
      [Servodvigatel],
      [AC servo 200 W, 0.64 / 1.91 N·m, 3000 ayl/min],
      [moment xarakteristikalari (5), tekşiruv hisobi (7)],
      [Uzatma], [şarik-vintli juftlik 12 × 10 mm, $Delta x = 1.0$ µm], [sikl böyiça tanlaş (11)],
      [Kritik aylaniş çastotasi], [11 535 ayl/min (ruxsat etilgan)], [katalog va FEM (7, 10)],
      [Qattiq tayanç], [2 × 7000 (O-sxema), kompensator 0.10--0.30 mm], [ölçam zanjiri (8)],
      [Mahkamlaş], [2 × M5 (5 N·m) + 2 × ştift Ø4], [boltli birikma (9)],
      [Asos], [U-profil, $t = 8$ mm, $h = 31$ mm, 2.01 kg], [optimallaştiriş (11)],
      [Salqilik / birinçi çastota], [9.1 µm / 154 Hz (analitik)], [bikrlik va modal tahlil (9--11)],
      [Takroriy pozitsiyalaş aniqligi], [$plus.minus 0.01$ mm], [texnik topşiriq],
      [Hisobiy massa], [7.09 kg], [spetsifikatsiya (@lst-spets)],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Yakuniy çiziqli modulning asosiy tavsiflari va ularning asoslanişi],
  placement: auto,
) <tab-final>

= Amaliy maşğulotni bajariş tartibi

== 1-topşiriq: texnik topşiriq tuziş

+ GOST 15.016 tuzilmasi böyiça modulning texnik topşirigini tuzing (@tab-tz). Texnik talablar bölimiga 7- va 11-maşğulotlardagi talablarni (yuriş, yuk, tezlik, harakat sikli, aniqlik, birinçi xususiy çastota) kiriting.
+ Har bir talabning qanday tekşirilişini aniqlang va uni sinov dasturiga (4-topşiriq) boğlang.

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (auto, 1fr),
      align: (left + horizon, left + horizon),
      stroke: none,
      inset: (x: 5pt, y: 4.5pt),
      table.hline(stroke: 1pt),
      table.header([*Bölim*], [*Namunaviy mazmuni*]),
      table.hline(stroke: 0.5pt),
      [1. Nomi va qöllaniliş sohasi],
      [Çiziqli pozitsiyalaş moduli MMK.12; avtomatlaştirilgan yiğiş va olib-qöyiş qurilmalari uçun],
      [2. Işlab çiqiş uçun asos], [fan öquv dasturi, kurs loyihasi topşirigi],
      [3. Maqsadi], [yuk karetkasini dasturlanadigan holatlarga aniq va tez siljitiş],
      [4. Texnik talablar],
      [yuriş 300 mm; yuk 5 kg; $v_max >= 0.5$ m/s; 20 mm siljiş $<= 50$ ms; takroriy aniqlik $plus.minus 0.01$ mm; $f_1 >= 150$ Hz; taʼminot 230 V, 50 Hz; işlaş harorati $+5 dots +40$ °C],
      [5. Işonçlilik va texnik xizmat], [şarik-vintli juftlik resursi kamida 10 000 km; moylaş oraliği 100 km],
      [6. Işlab çiqiş bosqiçlari], [eskiz loyiha, texnik loyiha, işçi hujjatlar, tajriba nusxasi],
      [7. Nazorat va qabul qiliş], [ПМ hujjati böyiça qabul sinovlari (@tab-pm)],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Texnik topşiriq tuzilmasi va namunaviy mazmuni (GOST 15.016 asosida)],
) <tab-tz>

== 2-topşiriq: belgilaş va spetsifikatsiya

+ Modulning barça tarkibiy qismlariga (@fig-tree) tuzilmaviy belgilar bering va ularni CAD fayl xossalariga (_Custom Properties_: belgi, nomi, material, massa) kiriting. Kompensator qistirmalar uçun ijrolarni konfiguratsiyalar sifatida rasmiylaştiring.
+ CAD tizimidan yuqori yiğmaning tarkibini (BOM) CSV formatida eksport qiling.
+ @lst-spets dagi dastur yordamida spetsifikatsiyani GOST 2.106 dagi bölimlar tartibida şakllantiring: hujjatlar, yiğma birliklar, detallar, standart buyumlar, boşqa buyumlar, materiallar. Hujjatlarga pozitsiya raqami berilmaydi. Standart va boşqa buyumlar nomi böyiça alifbo tartibida joylaştiriladi. Natijani CAD tizimining spetsifikatsiya moduli bilan solişting.

#figure(
  ```python
  import csv
  import io
  from collections import defaultdict

  # CAD dan eksport qilingan yuqori yiğma tarkibi (BOM, soddalaştirilgan)
  BOM = """belgi;nomi;soni;massa;bolim
  MMK.12.00.00.000 СБ;Yiğma çizmasi;;;Hujjatlar
  MMK.12.00.00.000 Э3;Elektr prinsipial sxemasi;;;Hujjatlar
  MMK.12.00.00.000 РЭ;Işlatiş qöllanmasi;;;Hujjatlar
  MMK.12.01.00.000;Yuritma yiğmasi;1;1.39;Yiğma birliklar
  MMK.12.02.00.000;Qattiq tayanç yiğmasi;1;0.35;Yiğma birliklar
  MMK.12.03.00.000;Suzuvçi tayanç yiğmasi;1;0.22;Yiğma birliklar
  MMK.12.04.00.000;Karetka yiğmasi;1;1.35;Yiğma birliklar
  MMK.12.00.00.001;Asos profili;1;2.01;Detallar
  MMK.12.00.00.002;Tirgak;2;0.03;Detallar
  ;Vint M5×16 ISO 4762;8;0.004;Standart buyumlar
  ;Vint M4×12 ISO 4762;16;0.002;Standart buyumlar
  ;Ştift 4×12 ISO 8734;4;0.001;Standart buyumlar
  ;Profil rels 15 mm, L = 440 mm;2;0.62;Boşqa buyumlar
  ;Şarik-vintli juftlik 12×10, L = 400 mm;1;0.36;Boşqa buyumlar
  ;Çegara datçigi, induktiv, M8;2;0.02;Boşqa buyumlar
  """
  ORDER = ["Hujjatlar", "Yiğma birliklar", "Detallar",
           "Standart buyumlar", "Boşqa buyumlar", "Materiallar"]

  groups = defaultdict(list)
  for r in csv.DictReader(io.StringIO(BOM), delimiter=";"):
      groups[r["bolim"]].append(r)

  pos, total = 1, 0.0
  for sec in ORDER:
      if sec not in groups:
          continue
      print(f"\n{sec:^64}")
      # hujjatlar berilgan tartibda, standart va boşqa buyumlar nomi,
      # qolganlari belgisi böyiça saralanadi
      rows = groups[sec]
      if sec in ("Standart buyumlar", "Boşqa buyumlar"):
          rows = sorted(rows, key=lambda r: r["nomi"])
      elif sec != "Hujjatlar":
          rows = sorted(rows, key=lambda r: r["belgi"])
      for r in rows:
          if sec == "Hujjatlar":              # hujjatlarga pozitsiya berilmaydi
              print(f"{'':3}  {r['belgi']:<22} {r['nomi']}")
              continue
          n, m = int(r["soni"]), float(r["massa"])
          total += n * m
          print(f"{pos:3d}  {r['belgi']:<22} {r['nomi']:<38} {n:3d}")
          pos += 1
  print(f"\nYiğmaning hisobiy massasi: {total:.2f} kg")
  ```,
  caption: [CAD dan eksport qilingan tarkib asosida spetsifikatsiyani şakllantiriş],
  placement: auto,
) <lst-spets>

Dastur natijasi:

```text
                           Hujjatlar                            
     MMK.12.00.00.000 СБ    Yiğma çizmasi
     MMK.12.00.00.000 Э3    Elektr prinsipial sxemasi
     MMK.12.00.00.000 РЭ    Işlatiş qöllanmasi

                        Yiğma birliklar                         
  1  MMK.12.01.00.000       Yuritma yiğmasi                          1
  2  MMK.12.02.00.000       Qattiq tayanç yiğmasi                    1
  3  MMK.12.03.00.000       Suzuvçi tayanç yiğmasi                   1
  4  MMK.12.04.00.000       Karetka yiğmasi                          1

                            Detallar                            
  5  MMK.12.00.00.001       Asos profili                             1
  6  MMK.12.00.00.002       Tirgak                                   2

                       Standart buyumlar                        
  7                         Vint M4×12 ISO 4762                     16
  8                         Vint M5×16 ISO 4762                      8
  9                         Ştift 4×12 ISO 8734                      4

                         Boşqa buyumlar                         
 10                         Profil rels 15 mm, L = 440 mm            2
 11                         Çegara datçigi, induktiv, M8             2
 12                         Şarik-vintli juftlik 12×10, L = 400 mm   1

Yiğmaning hisobiy massasi: 7.09 kg
```

== 3-topşiriq: grafik hujjatlar

+ *Yiğma çizmasi* (MMK.12.00.00.000 СБ): kerakli körinişlar va qirqimlarni tanlang, spetsifikatsiyaga mos pozitsiya raqamlarini qöying. Gabarit, montaj va ulaniş ölçamlarini körsating. Texnik talablarni yozing (@tab-tt).
+ *Detal çizmasi* (MMK.12.02.00.001, korpus): Ø26H7 teşik, yelkaning teşik öqiga perpendikulyarligi (0.01 mm), podşipnik örni uçun $R a$ 0.8, umumiy dopusklar ISO 2768-mK, material va qoplamani körsating. Asosiy yozuvni @fig-title böyiça töldiring.
+ *Gabarit çizma* (ГЧ): modulning gabarit ölçamlari, asosga mahkamlaş teşiklari, karetkadagi foydali yuk ulaniş teşiklari va massa markazini körsating.
+ *Elektr prinsipial sxemasi* (Э3): @fig-e3 asosida sxemani elektr sxemalar tizimida bajaring va elementlar röyxatini (@tab-elem) tuzing.

#figure(
  cetz.canvas(length: 0.88cm, {
    import cetz.draw: *
    set-style(content: (padding: 1.5pt))
    let blk(c, w, h, fill, body) = {
      rect(
        (c.at(0) - w / 2, c.at(1) - h / 2),
        (c.at(0) + w / 2, c.at(1) + h / 2),
        fill: fill,
        stroke: 1pt + dslate,
      )
      content(c, align(center, text(size: 7.5pt, body)))
    }
    let wire(..pts) = line(..pts, stroke: 0.9pt + dslate)
    let lbl(p, body, anc) = content(p, text(size: 6.5pt, body), anchor: anc)

    // Tarmoq
    for (y, n) in ((6.2, "L"), (5.7, "N")) {
      wire((0, y), (1.2, y))
      lbl((0, y + 0.05), n, "south-west")
    }
    wire((0, 4.6), (16.2, 4.6))
    lbl((0, 4.65), "PE", "south-west")
    lbl((0, 6.8), [\~230 V, 50 Hz], "south-west")

    // QF1
    blk((1.8, 5.95), 1.2, 1.1, white)[QF1]
    // A1 ga va G1 ga
    wire((2.4, 6.2), (8.0, 6.2))
    wire((2.4, 5.7), (8.0, 5.7))
    wire((3.2, 6.2), (3.2, 7.6), (4.0, 7.6))
    wire((3.6, 5.7), (3.6, 7.2), (4.0, 7.2))
    circle((3.2, 6.2), radius: 0.05, fill: dslate)
    circle((3.6, 5.7), radius: 0.05, fill: dslate)
    blk((5.0, 7.4), 2.0, 1.0, yellow.lighten(80%))[G1 \ 230 V\~ / 24 V=]
    // 24 V
    wire((6.0, 7.6), (9.5, 7.6), (9.5, 7.1))
    wire((6.0, 7.2), (9.0, 7.2), (9.0, 7.1))
    lbl((7.0, 7.65), "+24 V", "south")
    lbl((7.0, 7.15), "0 V", "north")

    // A1 servodrayver
    blk((9.5, 4.6), 3.0, 5.0, green.lighten(88%))[*A1* \ Servodrayver \ 200 W]
    for (y, n) in ((6.2, "L1"), (5.7, "L2"), (4.6, "PE")) { lbl((8.05, y), n, "west") }
    for (y, n) in ((6.2, "U"), (5.8, "V"), (5.4, "W"), (3.4, "CN2"), (2.6, "BRK")) { lbl((10.95, y), n, "east") }
    for (y, n) in ((3.0, "LIM+"), (2.6, "LIM−")) { lbl((8.05, y), n, "west") }
    lbl((9.0, 7.05), "24V", "north")
    lbl((9.5, 2.15), "CN3", "south")

    // M1
    circle((14.6, 5.6), radius: 0.85, fill: blue.lighten(88%), stroke: 1pt + dslate)
    content((14.6, 5.6), text(size: 8pt)[M1 \ M 3\~])
    wire((11.0, 6.2), (13.9, 6.2))
    wire((11.0, 5.8), (13.75, 5.8))
    wire((11.0, 5.4), (13.75, 5.4))
    wire((16.2, 4.6), (16.2, 5.6), (15.45, 5.6))
    // BQ1 enkoder va YB1 tormoz
    blk((14.6, 3.4), 1.4, 0.7, white)[BQ1]
    blk((14.6, 2.4), 1.4, 0.7, white)[YB1]
    line((14.6, 4.75), (14.6, 3.75), stroke: (paint: dslate, thickness: 0.8pt, dash: "dashed"))
    line((14.6, 3.05), (14.6, 2.75), stroke: (paint: dslate, thickness: 0.8pt, dash: "dashed"))
    wire((11.0, 3.4), (13.9, 3.4))
    wire((11.0, 2.6), (12.6, 2.6), (12.6, 2.4), (13.9, 2.4))
    lbl((12.4, 3.45), "enkoder", "south")
    lbl((12.0, 2.65), "tormoz 24 V", "south")

    // SQ1, SQ2
    for (y, n) in ((3.0, "SQ1"), (2.6, "SQ2")) {
      wire((4.0, y), (5.2, y))
      line((5.2, y), (5.8, y + 0.3), stroke: 0.9pt + dslate)
      wire((5.9, y), (8.0, y))
      lbl((4.6, y + 0.05), n, "south")
    }
    wire((4.0, 3.0), (4.0, 2.2), (6.0, 2.2), (6.0, 1.6))
    lbl((6.1, 1.6), "0 V", "west")

    // A2 kontroller
    blk((9.5, 0.7), 3.6, 0.9, purple.lighten(88%))[*A2* \ Boşqaruv kontrolleri]
    wire((9.5, 2.1), (9.5, 1.15))
    lbl((9.6, 1.6), "EtherCAT", "west")
  }),
  caption: [Çiziqli modulning elektr prinsipial sxemasi (soddalaştirilgan, Э3)],
  placement: auto,
) <fig-e3>

== 4-topşiriq: matnli va işlatiş hujjatlari, özgarişlar

+ *Tuşuntiriş xati* (ПЗ) tuzilmasini tuzing: kiriş, tadqiqot natijalari (4--6-tajribalar), konstruksiya tavsifi (7--8), hisob-kitoblar (9--11), xulosa. Har bir bölimga tegişli maşğulot natijalarini kiriting.
+ *Işlatiş qöllanmasi* (РЭ) bölimlarini yozing: xavfsizlik talablari (9-maşğulotdagi favqulodda holat, tok çegarasi va çegara datçiklari), örnatiş (asosni qattiq ramaga mahkamlaş), işga tuşiriş, kompensator tanlaş tartibi (8), texnik xizmat (moylaş oraliği, boltlar tortiş momentini tekşiriş).
+ *Sinov dasturi va metodikasi* (ПМ) böyiça qabul sinovlari röyxatini tuzing (@tab-pm). Har bir sinov uçun qabul mezoni texnik topşiriqdagi talabga mos kelişi kerak.
+ *Özgariş kiritiş:* 8-maşğulotdagi DFA tahlili natijasida qopqoq boltlari soni 4 tadan 2 taga kamaytirilgan. Şu özgariş uçun özgariş xabarnomasini tuzing (@tab-change). Özgariş taʼsir qiladigan barça hujjatlarni (yiğma çizmasi, spetsifikatsiya) aniqlang.

= Namunaviy hujjat fragmentlari

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (auto, 1fr),
      align: (center + top, left + top),
      stroke: none,
      inset: (x: 5pt, y: 4pt),
      table.hline(stroke: 1pt),
      [1.], [\*Ölçamlar uçun maʼlumot.],
      [2.],
      [Kompensator qistirma (MMK.12.02.00.004-01…-03) qalinligi yiğişda tanlanadi: qopqoq va korpus orasidagi tirqiş $s = 0.02 dots 0.14$ mm bölişi kerak.],
      [3.],
      [Boltlarni tortiş momentlari: M5 --- 5 N·m, M4 --- 3 N·m. Rezbalarga örta mustahkamlikdagi rezba fiksatori surting.],
      [4.],
      [Relslarning özaro parallelligi va vint öqining relslarga parallelligi butun uzunlik böyiça 0.02 mm dan oşmasin.],
      [5.],
      [Yiğilgan modulda karetka butun yuriş böyiça bir tekis, tiqilişsiz harakatlanişi kerak. Salt yurişdagi aylaniş momenti 0.05 N·m dan oşmasin.],
      [6.], [Şarik-vintli juftlik va karetka bloklarini litiyli surkov bilan moylang.],
      [7.], [Qolgan texnik talablar --- MMK.12.00.00.000 ТУ böyiça.],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Yiğma çizmasidagi texnik talablar (namunaviy matn)],
  placement: auto,
) <tab-tt>

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (auto, auto, 1fr, auto),
      align: (center + horizon, left + horizon, left + horizon, center + horizon),
      stroke: none,
      inset: (x: 5pt, y: 4.5pt),
      table.hline(stroke: 1pt),
      table.header([*Poz. belgi*], [*Nomi*], [*Tavsifi*], [*Soni*]),
      table.hline(stroke: 0.5pt),
      [A1], [Servodrayver], [AC 230 V, 200 W, EtherCAT], [1],
      [A2], [Boşqaruv kontrolleri], [PLC, EtherCAT master], [1],
      [BQ1], [Enkoder], [2500 PPR, M1 tarkibida], [1],
      [G1], [Taʼminot bloki], [230 V\~ / 24 V=, 2.5 A], [1],
      [M1], [Servodvigatel], [200 W, 3000 ayl/min], [1],
      [QF1], [Avtomatik uzgiç], [2 qutbli, C6], [1],
      [SQ1, SQ2], [Çegara datçigi], [induktiv, M8, PNP], [2],
      [YB1], [Elektromagnit tormoz], [24 V=, M1 tarkibida], [1],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Elektr prinsipial sxemasining elementlar röyxati (fragment)],
) <tab-elem>

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (1fr, 1.3fr, auto),
      align: (left + horizon, left + horizon, left + horizon),
      stroke: none,
      inset: (x: 5pt, y: 4.5pt),
      table.hline(stroke: 1pt),
      table.header([*Sinov*], [*Metodika (maşğulot)*], [*Qabul mezoni*]),
      table.hline(stroke: 0.5pt),
      [Takroriy pozitsiyalaş aniqligi],
      [ISO 230-2, lazer interferometr, 5 holat × 5 marta (4-tajriba metodologiyasi)],
      [$<= plus.minus 0.01$ mm],
      [Salt yurişdagi aylaniş momenti], [servodrayver toki böyiça, $T = k_t I$ (5-tajriba)], [$<= 0.05$ N·m],
      [Harakat sikli], [20 mm siljiş, 0.1 s turiş (11-maşğulot)], [$t_m <= 50$ ms],
      [Birinçi xususiy çastota],
      [modal bolğa bilan zarbali sinov, $H_1$ baholaş (6-tajriba, 10-maşğulot)],
      [$>= 150$ Hz],
      [Qattiq tayanç tirqişi], [çuqurlik ölçagiç va mikrometr (8-maşğulot)], [$0.02 dots 0.14$ mm],
      [Qiziş], [II sikl böyiça 1 soat uzluksiz iş], [dvigatel korpusining harorat oşişi $<= 40$ K],
      [Çegara datçiklari va favqulodda töxtaş],
      [karetkani past tezlikda çetki holatga yuboriş],
      [tirgakgaça kamida 5 mm qolganda töxtaş],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Qabul sinovlari dasturi (ПМ, namunaviy fragment)],
  placement: auto,
) <tab-pm>

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (auto, 1fr),
      align: (left + horizon, left + horizon),
      stroke: 0.5pt + luma(150),
      inset: (x: 6pt, y: 4.5pt),
      [*Xabarnoma*], [MMK-01],
      [*Hujjatlar*], [MMK.12.02.00.000 СБ, MMK.12.02.00.000 (spetsifikatsiya)],
      [*Özgariş №*], [1],
      [*Sabab*],
      [yiğiş texnologikligini oşiriş (DFA tahlili, 8-maşğulot); öq kuçi bölgan 32 N 2 ta bolt bilan işonçli uzatiladi],

      [*Edi*], [Vint M5×16 ISO 4762 --- 4 ta; qopqoqda 4 ta teşik],
      [*Böldi*], [Vint M5×16 ISO 4762 --- 2 ta; qopqoqda 2 ta teşik (MMK.12.02.00.002 detal çizmasi ham özgaradi)],
      [*Joriy etiş*], [keyingi partiyadan; tayyor qopqoqlardan foydalaniş mumkin],
    )
  },
  caption: [Özgariş xabarnomasi (GOST 2.503 asosida, namunaviy)],
  placement: auto,
) <tab-change>

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (auto, auto, auto, 1fr, auto),
      align: (left + horizon, center + horizon, center + horizon, left + horizon, center + horizon),
      stroke: none,
      inset: (x: 5pt, y: 4.5pt),
      table.hline(stroke: 1pt),
      table.header([*Bosqiç*], [*GOST*], [*Litera*], [*Asosiy hujjatlar*], [*Maşğulotlar*]),
      table.hline(stroke: 0.5pt),
      [Texnik topşiriq], [15.016], [—], [ТЗ], [12],
      [Texnik taklif], [2.118], [П], [ПЗ, tadqiqot natijalari], [4--6],
      [Eskiz loyiha], [2.119], [Э], [umumiy köriniş (ВО), 3D maket, ПЗ], [7],
      [Texnik loyiha], [2.120], [Т], [ВО, hisob-kitoblar (РР), ПЗ], [8--11],
      [Işçi hujjatlar], [2.102], [О, О#sub[1], А], [СБ, detal çizmalari, spetsifikatsiya, Э3, ТУ, ПМ, РЭ], [12],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Loyihalaş bosqiçlari, literalar va hujjatlar],
) <tab-stages>

Bu fragmentlar hujjatlar orasidagi boğliqlikni körsatadi:
- texnik topşiriqdagi har bir talab (@tab-tz) sinov dasturida aniq ölçaş usuli va qabul mezoniga ega (@tab-pm);
- yiğma çizmasidagi texnik talablar (@tab-tt) 8- va 9-maşğulotlardagi hisoblarga asoslanadi;
- özgariş xabarnomasi (@tab-change) bir vaqtning özida bir neça hujjatga taʼsir qiladi.

Hujjatlar majmuasining sifati aynan şu izçillik bilan baholanadi. Bir hujjatdagi qiymat özgarganda u bilan boğliq barça hujjatlar ham yangilanişi kerak. Buning uçun belgi, nom, material va massa kabi maʼlumotlarni CAD modelining xossalarida yagona manba sifatida saqlaş va hujjatlarni ulardan avtomatik şakllantiriş tavsiya etiladi. Spetsifikatsiya dasturi (@lst-spets) şu yondaşuvning oddiy namunasidir.

= Nazorat savollari

+ GOST 2.101 böyiça buyumlarning qanday turlari mavjud? Çiziqli modul va uning qismlari qaysi turlarga kiradi?
+ Loyihalaş bosqiçlari va literalar nima uçun kerak?
+ Yiğma birlik va detal uçun asosiy konstruktorlik hujjati qaysi?
+ GOST 2.201 böyiça belgi qanday tuzilgan? Tuzilmaviy belgilaşning afzalligi nimada?
+ Ijro nima va u CAD dagi konfiguratsiyalar bilan qanday boğlanadi?
+ Spetsifikatsiya qanday bölimlardan iborat va ular qanday tartibda joylaşadi?
+ Detal çizmasida qanday dopusklar va sirt ğadir-budurligi körsatiladi? Umumiy dopusklar qanday beriladi?
+ Э3 kodi nimani bildiradi? GOST 2.710 böyiça A, M, BQ, SQ, QF harflari nimani anglatadi?
+ Texnik topşiriq va sinov dasturi orasida qanday boğliqlik bölişi kerak?
+ Hujjatga özgariş qanday kiritiladi va özgariş xabarnomasida nimalar körsatiladi?
