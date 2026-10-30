// ============================================================
//  Mexatron modullarni konstruksiyalaş — Konstruktiv parametrlarni optimallaştiriş — amaliy maşğulot — Typst versiyasi
//  Kompilyatsiya: typst compile amaliy_11.typ
// ============================================================

#import "@preview/cetz:0.4.2"

#let headingblue = rgb(20, 50, 120)

#set document(title: "Mexatron modulning konstruktiv parametrlarini optimallaştiriş")
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
  #text(size: 20pt, weight: "bold", fill: headingblue)[AMALIYOT MAŞĞULOTI №11]
  #v(0.4cm)
  #text(
    size: 14pt,
    weight: "bold",
  )[Mavzu: Mexatron modulning konstruktiv parametrlarini optimallaştiriş]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Işning maqsadi

*Maşğulotning maqsadi:* mexatron modulning konstruktiv parametrlarini matematik optimallaştiriş usullari yordamida tanlaşni örganiş. 7--10-maşğulotlarda loyihalangan çiziqli modul misolida quyidagi könikmalarni hosil qiliş:
- optimallaştiriş masalasini qöyiş: loyiha özgaruvçilari, maqsad funksiyasi va çeklovlarni aniqlaş;
- asos profilini massa böyiça gradient usulida (SLSQP) optimallaştiriş;
- köp mezonli masalada Pareto front quriş;
- sezgirlik tahlilini bajariş;
- şarik-vintli uzatmaning diametri va qadamini harakat sikli böyiça diskret tanlaş;
- optimal yeçimni CAD/FEA muhitida tekşiriş.

= Dasturiy va texnik taʼminot

+ *Python (NumPy, SciPy):* `scipy.optimize.minimize` (SLSQP usuli) va saralaş algoritmlari (@lst-profil, @lst-uzatma).
+ *CAD/FEA tizimi:* SolidWorks (Design Study, Topology Study), Autodesk Inventor (Parametric Study, Shape Generator) yoki Fusion 360 (Generative Design). Bepul muqobil sifatida FreeCAD + Python skriptlari qöllanilişi mumkin.
+ *Dastlabki maʼlumotlar:* 7-maşğulotdagi modul parametrlari, 9-maşğulotdagi bikrlik talabi ($[f] = 10$ µm) va 10-maşğulotdagi modal tahlil natijalari.

= Konstruktiv optimallaştirişning nazariy asoslari

== Optimallaştiriş masalasining qöyilişi

Konstruktiv optimallaştiriş masalasi umumiy holda quyidagiça yoziladi:

$
  min_(bold(x)) thin f(bold(x)), quad g_j (bold(x)) <= 0 quad (j = 1, dots, m), quad bold(x)_L <= bold(x) <= bold(x)_U
$ <eq-problem>

bunda $bold(x)$ --- loyiha özgaruvçilari vektori (ölçamlar, qadam, material), $f(bold(x))$ --- maqsad funksiyasi (massa, narx, harakat vaqti), $g_j$ --- çeklovlar (mustahkamlik, bikrlik, xususiy çastota, moment), $bold(x)_L$ va $bold(x)_U$ --- texnologik va gabarit çegaralar. Barça çeklovlarni qanoatlantiruvçi nuqtalar töplami *ruxsat etilgan soha* deyiladi.

Optimal nuqtada çeklovlarning bir qismi aktiv ($g_j = 0$) böladi. Silliq masalalar uçun optimallik şarti Karuş--Kun--Takker (KKT) şartlari bilan ifodalanadi:

$ nabla f + sum_j lambda_j nabla g_j = bold(0), quad lambda_j >= 0, quad lambda_j g_j = 0 $ <eq-kkt>

Lagranj köpaytuvçisi $lambda_j$ amaliy maʼnoga ega: u $j$-çeklovni biroz yumşatganda maqsad funksiyasi qançaga yaxşilanişini körsatadi. Aktiv bölmagan çeklovlar uçun $lambda_j = 0$.

== Optimallaştiriş usullari

- *Saralaş va tajribalarni rejalaştiriş* (DOE): loyiha sohasi tör böyiça hisoblanadi. Usul oddiy va işonçli, lekin özgaruvçilar köpaysa hisob hajmi keskin oşadi.
- *Gradient usullari* (SQP, SLSQP): silliq masalalar uçun tez yaqinlaşadi. Biroq global optimumni kafolatlamaydi, şuning uçun turli boşlanğiç nuqtalardan tekşiriş kerak.
- *Gradientsiz usullar* (Nelder--Mid, genetik algoritmlar): sakraşli yoki şovqinli funksiyalar uçun qöllaniladi, lekin köp hisob talab qiladi.
- *Diskret özgaruvçilar* (standart qadam, diametr, podşipnik turi) katalog qiymatlarini saralaş yöli bilan tanlanadi.
- *Topologik optimallaştiriş* (CAD tizimlarida): material taqsimotini bikrlik/massa nisbati böyiça avtomatik aniqlaydi va yangi konstruktiv şakl ğoyasini beradi.

== Köp mezonli optimallaştiriş va sezgirlik

Agar bir neça maqsad bir-biriga zid bölsa (masalan, massa va xususiy çastota), yagona optimum bölmaydi. Bunda *Pareto front* quriladi. U şunday yeçimlar töplamidan iborat: ularda bir mezonni yaxşilaş uçun boşqasini yomonlaştiriş şart. Pareto frontini qurişning amaliy usuli $epsilon$-çeklov usulidir: bir mezon maqsad funksiyasi qilib olinadi, ikkinçisi esa özgaruvçan çeklov $g(bold(x)) >= epsilon$ sifatida beriladi.

Normallaştirilgan sezgirlik koeffitsienti loyiha özgaruvçisining nisbiy özgarişi natijani qançaga özgartirişini körsatadi:

$ S_(y, x) = (partial y) / (partial x) dot x / y $ <eq-sens>

Masalan, $S = 2$ bölsa, $x$ ni 1 % ga oşiriş $y$ ni taxminan 2 % ga oşiradi.

== Asos profili modeli

Asos plitasi U-şaklidagi profil bilan almaştiriladi: eni $b$ va qalinligi $t$ bölgan yuqori plita va ikki çetda qalinligi $w$, balandligi $h$ bölgan devorlar (@fig-profil). Kesim yuzasi, oğirlik markazi va inersiya momenti:

$ A = b t + 2 w h, quad y_c = (b t (h + t \/ 2) + w h^2) / A $ <eq-area>

$ I = (b t^3) / 12 + b t (h + t / 2 - y_c)^2 + 2 [(w h^3) / 12 + w h (h / 2 - y_c)^2] $ <eq-inertia>

Salqilik 9-maşğulotdagi tösin formulasi böyiça, birinçi xususiy çastota esa 10-maşğulotdagi Reley bahosi böyiça hisoblanadi:

$ f = (F L^3) / (48 E I), quad f_1 = 1 / (2 pi) sqrt((48 E I \/ L^3) / (m_c + 0.49 rho A L)) $ <eq-ff1>

== Uzatma qadamini optimallaştiriş

Şarik-vintli uzatmada qadam $p$ tezlik va tezlaniş orasidagi kelişuvni belgilaydi. Katta qadam yuqori tezlik beradi, lekin karetkaning dvigatel valiga keltirilgan inersiyasi $p^2$ ga proporsional oşadi. Moment böyiça çeklangan eng katta tezlaniş:

$ a_max (p) = ((T_max - T_f) thin p) / (2 pi J(p)), quad J(p) = J_0 + m_k (p / (2 pi))^2 $ <eq-amax>

bunda $J_0 = J_m + J_c + J_v$ --- aylanuvçi qismlarning inersiyasi. Bu funksiya inersiyalar moslaşgan nuqtada maksimumga erişadi:

$ (d a_max) / (d p) = 0 quad => quad m_k (p_"opt" / (2 pi))^2 = J_0, quad p_"opt" = 2 pi sqrt(J_0 / m_k) $ <eq-popt>

Trapetsiyasimon tezlik profilida $s$ masofani bosib ötiş vaqti:

$
  t_m = cases(
    s / v_max + v_max / a & "agar" s >= v_max^2 \/ a,
    2 sqrt(s \/ a) & "aks holda"
  )
$ <eq-tmove>

bunda $v_max = min(n_"dv", n_"cr") thin p \/ 60$ --- dvigatel va vintning kritik çastotasi bilan çeklangan tezlik. Dvigatelning qizib ketmasligi uçun sikl davomidagi örtaça kvadratik moment nominal momentdan oşmasligi kerak:

$ T_"rms" = sqrt((sum_i T_i^2 t_i) / t_"sikl") <= T_n $ <eq-trms>

= Amaliy maşğulotni bajariş tartibi

== 1-topşiriq: asos profilini massa böyiça optimallaştiriş

+ @tab-problem dagi masalani tahlil qiling: loyiha özgaruvçilari, maqsad funksiyasi va çeklovlarni aniqlang. Pastki çegara $t >= 8$ mm rels boltlari (M4) uçun rezba çuqurligi ($2 d$) talabidan kelib çiqadi.
+ @lst-profil dagi dasturni işga tuşiring. Optimal $t$, $h$ va massani aniqlang. Qaysi çeklovlar aktiv ekanini tekşiring.
+ Loyiha sohasida (@fig-space) çeklov çiziqlarini, teng massa çiziqlarini va optimal nuqtani körsating. Dasturni 3 xil boşlanğiç nuqtadan işga tuşirib, natija özgarmasligini tekşiring.
+ Optimal yeçimni texnologik ölçamlarga yaxlitlang va 9-maşğulotdagi variantlar bilan solişting (@tab-compare).

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
      table.header([*Element*], [*Tavsifi*]),
      table.hline(stroke: 0.5pt),
      [Loyiha özgaruvçilari], [$t$ --- plita qalinligi, $h$ --- devor balandligi],
      [Özgarmas parametrlar], [$b = 140$ mm, $w = 8$ mm, $L = 440$ mm, $m_c = 6.35$ kg, AW-6061],
      [Maqsad funksiyasi], [asos massasi $m = rho A L_a -> min$],
      [Çeklovlar], [$g_1$: $f <= 10$ µm (pozitsiyalaş aniqligi); \ $g_2$: $f_1 >= 150$ Hz (boşqaruv ötkazuvçanligi)],
      [Çegaralar], [$8 <= t <= 40$ mm (rezba çuqurligi), $0 <= h <= 60$ mm (gabarit)],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Asos profilini optimallaştiriş masalasi],
  placement: auto,
) <tab-problem>

#figure(
  cetz.canvas(length: 0.075cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // masştab 1:1 (mm), b = 140, t = 8, h = 31, w = 8
    let b = 140
    let t = 8
    let h = 31
    let w = 8
    rect((0, h), (b, h + t), fill: blue.lighten(75%), stroke: 1pt + dslate)
    rect((0, 0), (w, h), fill: blue.lighten(75%), stroke: 1pt + dslate)
    rect((b - w, 0), (b, h), fill: blue.lighten(75%), stroke: 1pt + dslate)
    // relslar
    rect((25, h + t), (40, h + t + 12.5), fill: luma(190), stroke: 0.8pt + dslate)
    rect((100, h + t), (115, h + t + 12.5), fill: luma(190), stroke: 0.8pt + dslate)
    content((70, h + t + 6), text(size: 8pt)[relslar], anchor: "center")
    // ölçamlar
    line((0, -8), (b, -8), stroke: 0.7pt, mark: (start: ">", end: ">", fill: black, scale: 0.5))
    content((70, -9), text(size: 8pt)[$b = 140$], anchor: "north")
    line((b + 8, h), (b + 8, h + t), stroke: 0.7pt)
    content((b + 10, h + t / 2), text(size: 8pt)[$t$], anchor: "west")
    line((-8, 0), (-8, h), stroke: 0.7pt, mark: (start: ">", end: ">", fill: black, scale: 0.5))
    content((-10, h / 2), text(size: 8pt)[$h$], anchor: "east")
    line((b - w, -3), (b, -3), stroke: 0.7pt)
    content((b - w / 2, -3), text(size: 8pt)[$w$], anchor: "north")
    line((-14, 29), (b + 14, 29), stroke: (paint: red.darken(10%), thickness: 0.6pt, dash: "dash-dotted"))
    content((b + 15, 29), text(size: 8pt, fill: red.darken(20%))[$y_c$ (neytral öq)], anchor: "west")
  }),
  caption: [Asosning U-şaklidagi kesimi va loyiha özgaruvçilari (masştab 1:1, optimal variant)],
  placement: auto,
) <fig-profil>

#figure(
  ```python
  import numpy as np
  from scipy.optimize import minimize

  # Dastlabki maʼlumotlar (mm, N, MPa, kg)
  b, w, L, La = 140.0, 8.0, 440.0, 460.0   # eni, devor, oraliq, uzunlik
  E, rho = 69e3, 2.7e-6                    # AW-6061: MPa, kg/mm³
  F, m_c = 62.3, 6.35                      # karetka oğirligi (N) va massasi (kg)
  f_max, f1_min = 10e-3, 150.0             # ruxsat: salqilik (mm), çastota (Hz)

  def section(t, h):
      """U-profil: yuqorida b×t plita, ikki çetda w×h devor."""
      A1, A2 = b * t, 2 * w * h
      yc = (A1 * (h + t / 2) + A2 * h / 2) / (A1 + A2)
      I = (b * t**3 / 12 + A1 * (h + t / 2 - yc)**2
           + 2 * (w * h**3 / 12 + w * h * (h / 2 - yc)**2))
      return A1 + A2, I

  def mass(x):
      A, _ = section(*x)
      return rho * A * La

  def deflection(x):
      _, I = section(*x)
      return F * L**3 / (48 * E * I)

  def freq(x):                              # Reley usuli, nuqtaviy massa örtada
      A, I = section(*x)
      k = 48 * E * I / L**3 * 1e3           # N/m
      return np.sqrt(k / (m_c + 0.49 * rho * A * L)) / (2 * np.pi)

  cons = [{"type": "ineq", "fun": lambda x: f_max - deflection(x)},
          {"type": "ineq", "fun": lambda x: freq(x) - f1_min}]
  res = minimize(mass, x0=[15.0, 20.0], method="SLSQP",
                 bounds=[(8.0, 40.0), (0.0, 60.0)], constraints=cons)
  t, h = res.x
  print(f"t = {t:.2f} mm, h = {h:.2f} mm, massa = {mass(res.x):.3f} kg")
  print(f"f = {deflection(res.x) * 1e3:.2f} µm, f1 = {freq(res.x):.1f} Hz")
  ```,
  caption: [Asos profilini SLSQP usulida massa böyiça optimallaştiriş],
  placement: auto,
) <lst-profil>

Dastur natijasi:

```text
t = 8.00 mm, h = 30.24 mm, massa = 1.992 kg
f = 9.63 µm, f1 = 150.0 Hz
```

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // x: t, 8..32 mm (1 birlik = 2.4 mm); y: h, 0..60 mm (1 birlik = 7.5 mm)
    let fx(t) = (t - 8) / 2.4
    let fy(h) = h / 7.5
    let ts = (8, 10, 12, 14, 16, 18, 20, 22, 24, 26)
    let hf = (30.24, 28.48, 26.7, 24.79, 22.64, 20.14, 17.12, 13.24, 7.64, 0.0)
    let hd = (29.76, 27.75, 25.71, 23.5, 21.01, 18.07, 14.39, 9.33, 0.0, 0.0)
    // ruxsat etilgan soha (f1 >= 150 çiziğidan yuqorida)
    let poly = ts.zip(hf).map(((t, h)) => (fx(t), fy(h)))
    poly.push((fx(32), 0))
    poly.push((fx(32), fy(60)))
    poly.push((fx(8), fy(60)))
    line(..poly, close: true, fill: green.lighten(85%), stroke: none)
    grid(
      (0, 0),
      (10, 8),
      step: 1,
      stroke: 0.3pt + luma(220),
    )
    line((0, 0), (10.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    content((10.6, 0), text(size: 9pt)[$t$ \[mm\]], anchor: "west")
    line((0, 0), (0, 8.5), stroke: 1pt, mark: (end: ">", fill: black))
    content((0, 8.55), text(size: 9pt)[$h$ \[mm\]], anchor: "south")
    for t in (8, 12, 16, 20, 24, 28, 32) {
      content((fx(t), -0.1), text(size: 7.5pt)[#t], anchor: "north")
    }
    for h in range(0, 61, step: 15) {
      content((-0.1, fy(h)), text(size: 7.5pt)[#h], anchor: "east")
    }
    // teng massa çiziqlari: h = (m/(rho La) - b t)/(2 w)
    for m in (2.0, 3.0, 4.0) {
      let c = m / (2.7e-6 * 460)
      let h0 = (c - 140 * 8) / 16
      let t1 = calc.min(32, c / 140)
      let p0 = if h0 <= 60 { (fx(8), fy(h0)) } else { (fx((c - 16 * 60) / 140), fy(60)) }
      line(p0, (fx(t1), 0), stroke: (paint: luma(110), thickness: 0.7pt, dash: "dashed"))
      content((fx(t1) + 0.05, 0.25), text(size: 7pt, fill: luma(80))[#m kg], anchor: "south-west")
    }
    line(..ts.zip(hf).map(((t, h)) => (fx(t), fy(h))), stroke: 1.5pt + pblue)
    line(..ts.zip(hd).map(((t, h)) => (fx(t), fy(h))), stroke: 1.5pt + orange.darken(20%))
    content((fx(17), fy(26)), text(size: 8pt, fill: pblue)[$f_1 = 150$ Hz], anchor: "west")
    content((fx(18), fy(6)), text(size: 8pt, fill: orange.darken(30%))[$f = 10$ µm], anchor: "west")
    // nuqtalar
    circle((fx(8), fy(30.24)), radius: 0.13, fill: red, stroke: none)
    content(
      (fx(8) + 0.2, fy(30.24) + 0.25),
      text(size: 8pt, fill: red.darken(20%))[optimum: 1.99 kg],
      anchor: "south-west",
    )
    circle((fx(15), 0), radius: 0.12, fill: luma(100), stroke: none)
    content((fx(15), 0.25), text(size: 7pt)[15 mm \ (9-m.)], anchor: "south")
    circle((fx(25.5), 0), radius: 0.12, fill: luma(100), stroke: none)
    content((fx(27.0), 0.25), text(size: 7pt)[25.5 mm \ 4.43 kg], anchor: "south-west")
    content((fx(26), fy(50)), text(size: 8pt, fill: green.darken(40%))[ruxsat etilgan soha], anchor: "center")
  }),
  caption: [Asos profilining loyiha sohasi: çeklov çiziqlari, teng massa çiziqlari va optimal nuqta],
) <fig-space>

== 2-topşiriq: Pareto front va sezgirlik tahlili

+ $epsilon$-çeklov usulida salqilik çeklovini olib taşlang va $f_(1, min)$ ni 80 dan 300 Hz gaça özgartirib, har bir qiymat uçun minimal massani toping (@fig-pareto).
+ Pareto front qiyaligidan xususiy çastotani 1 Hz ga oşirişning "massa narxini" baholang.
+ Optimal nuqtada (@eq-sens) böyiça massa, salqilik va çastotaning $t$ va $h$ ga sezgirligini sonli differensiallaş bilan hisoblang (@tab-sens). Optimizator nima uçun $t$ ni pastki çegaraga olib borganini tuşuntiring.

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // x: f1, 50..325 Hz (1 birlik = 27.5 Hz); y: massa 1.5..4.5 kg (1 birlik = 0.375 kg)
    let fx(f) = (f - 50) / 27.5
    let fy(m) = (m - 1.5) / 0.375
    let pf = (
      (80, 1.728),
      (100, 1.809),
      (125, 1.904),
      (150, 1.992),
      (175, 2.077),
      (200, 2.158),
      (250, 2.315),
      (300, 2.465),
    )
    grid(
      (0, 0),
      (10, 8),
      step: 1,
      stroke: 0.3pt + luma(220),
    )
    line((0, 0), (10.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    content((10.6, 0), text(size: 9pt)[$f_1$ \[Hz\]], anchor: "west")
    line((0, 0), (0, 8.5), stroke: 1pt, mark: (end: ">", fill: black))
    content((0, 8.55), text(size: 9pt)[massa \[kg\]], anchor: "south")
    for f in (50, 105, 160, 215, 270, 325) {
      content((fx(f), -0.1), text(size: 7.5pt)[#f], anchor: "north")
    }
    for j in range(0, 9, step: 2) {
      content((-0.1, j), text(size: 7.5pt)[#calc.round(1.5 + 0.375 * j, digits: 2)], anchor: "east")
    }
    line(..pf.map(((f, m)) => (fx(f), fy(m))), stroke: 1.5pt + pblue)
    for (f, m) in pf { circle((fx(f), fy(m)), radius: 0.09, fill: pblue, stroke: none) }
    circle((fx(150), fy(1.992)), radius: 0.14, fill: red, stroke: none)
    content(
      (fx(150) + 0.15, fy(1.992) - 0.2),
      text(size: 8pt, fill: red.darken(20%))[tanlangan yeçim],
      anchor: "north-west",
    )
    // ustunlik qilinadigan (dominated) variantlar
    for (f, m, lbl) in ((71.6, 2.608, [tekis 15 mm]), (150.3, 4.434, [tekis 25.5 mm])) {
      circle((fx(f), fy(m)), radius: 0.12, fill: luma(110), stroke: none)
      content((fx(f) + 0.2, fy(m)), text(size: 7.5pt)[#lbl], anchor: "west")
    }
    content((fx(235), fy(2.6)), text(size: 8pt, fill: pblue)[Pareto front (U-profil)], anchor: "west")
    content((fx(200), fy(3.9)), text(size: 8pt, fill: luma(80))[ustunlik qilinadigan soha], anchor: "west")
  }),
  caption: [Asos massasi va birinçi xususiy çastota orasidagi Pareto front],
  placement: auto,
) <fig-pareto>

== 3-topşiriq: şarik-vintli uzatmani harakat sikli böyiça tanlaş

+ (@eq-popt) böyiça inersiyalar moslaşgan qadamni hisoblang.
+ @lst-uzatma dagi dastur yordamida ikki xil harakat sikli uçun standart variantlarni ($d = 12$ mm: $p = 5, 10$; $d = 16$ mm: $p = 5, 10, 16$) solişting:
  - I sikl: 300 mm, 0.5 s turiş, uzoq yuriş;
  - II sikl: 20 mm, 0.1 s turiş, olib-qöyiş (_pick-and-place_).

  Har bir variant uçun minimal harakat vaqti, tezlaniş, çöqqi va örtaça kvadratik momentni aniqlang (@tab-variants).
+ $d = 12$ mm uçun qadamni 2 dan 30 mm gaça uzluksiz özgartirib, harakat vaqtining qadamga boğliqligini quring (@fig-lead). Qaysi çeklov (tezlik, çöqqi moment yoki qiziş) qaysi sohada aktiv ekanini aniqlang.
+ Pozitsiyalaş rezolyutsiyasini ($Delta x = p \/ (4 N_"enk")$, $N_"enk" = 2500$ PPR) ham hisobga olib, har bir sikl uçun yakuniy variantni tanlang.

#figure(
  ```python
  import numpy as np

  # Dastlabki maʼlumotlar (SI)
  m_k, J_m, J_c = 6.35, 1.8e-5, 1.2e-6     # karetka+yuk, dvigatel, mufta
  rho, L_v, l_b = 7850.0, 0.40, 360.0       # vint: ziçlik, uzunlik, l_b (mm)
  T_max, T_n, n_mot = 1.91, 0.64, 3000.0    # dvigatel: N·m, N·m, ayl/min
  mu, eta, g = 0.01, 0.9, 9.81

  def cycle_time(d, d_r, p_mm, s, t_dw):
      """Çeklovlarni qanoatlantiruvçi eng qisqa harakat vaqti."""
      p = p_mm / 1000
      J_v = np.pi * rho * L_v * (d / 1000)**4 / 32
      J = J_m + J_c + J_v + m_k * (p / (2 * np.pi))**2
      T_f = mu * m_k * g * p / (2 * np.pi * eta)
      n_cr = 15.1 * d_r / l_b**2 * 1e7               # ruxsat etilgan
      v = min(n_mot, n_cr) * p / 60                  # tezlik çeklovi
      best = None
      for a in np.linspace(0.5, 200, 8000):          # tezlanişni saralaş
          if s >= v**2 / a:                          # trapetsiya
              t_a, t_m = v / a, s / v + v / a
          else:                                      # uçburçak
              t_a = np.sqrt(s / a)
              t_m = 2 * t_a
          T_acc = J * 2 * np.pi * a / p + T_f
          T_dec = J * 2 * np.pi * a / p - T_f
          t_c = t_m - 2 * t_a
          T_rms = np.sqrt(2 * (T_acc**2 * t_a + T_f**2 * t_c
                               + T_dec**2 * t_a) / (2 * t_m + 2 * t_dw))
          if T_acc <= T_max and T_rms <= T_n:        # moment çeklovlari
              best = (t_m, a, T_acc, T_rms)
      return best

  variants = [(12, 9.9, 5), (12, 9.9, 10),
              (16, 13.0, 5), (16, 13.0, 10), (16, 13.0, 16)]
  for name, s, t_dw in (("I", 0.300, 0.5), ("II", 0.020, 0.1)):
      for d, d_r, p in variants:
          t_m, a, T_acc, T_rms = cycle_time(d, d_r, p, s, t_dw)
          print(f"{name}: {d}x{p:<2d} t={t_m * 1e3:6.1f} ms, a={a:5.1f}, "
                f"T_pk={T_acc:.2f}, T_rms={T_rms:.2f}")
  ```,
  caption: [Şarik-vintli uzatma variantlarini harakat sikli böyiça soliştiriş],
  placement: auto,
) <lst-uzatma>

== 4-topşiriq: optimal yeçimni CAD/FEA da tekşiriş

+ 7-maşğulotdagi parametrik modelda asos plitasini optimal U-profil bilan almaştiring ($t = 8$ mm, $h = 31$ mm). Model avtomatik qayta qurilganini tekşiring.
+ 10-maşğulotdagi FEM modeli asosida statik salqilik va birinçi xususiy çastotani hisoblang. Natijalarni @tab-compare dagi analitik qiymatlar bilan solişting va farqni tuşuntiring.
+ CAD tizimining parametrik tadqiqot moduli (_Design Study_) yordamida $h$ ni 20--40 mm oraliğida özgartirib, FEA asosidagi optimumni toping va uni Python natijasi bilan solişting.
+ (Ixtiyoriy) Motor flanesi yoki tayanç korpusi uçun topologik optimallaştiriş bajaring: massani 40 % ga kamaytiriş, bikrlikni maksimallaştiriş. Olingan şaklni tayyorlaş texnologiyasiga moslab qayta modellang.

= Natijalar jadvallari

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (1.4fr, auto, auto, auto, auto, auto, auto),
      align: (
        left + horizon,
        center + horizon,
        center + horizon,
        center + horizon,
        center + horizon,
        center + horizon,
        center + horizon,
      ),
      stroke: none,
      inset: (x: 4pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*Variant*],
        [*$A$ \ \[mm²\]*],
        [*$I$ \ \[$10^3$ mm⁴\]*],
        [*Massa \ \[kg\]*],
        [*$f$ \ \[µm\]*],
        [*$f_1$ \ \[Hz\]*],
        [*FEA \ $f thin \/ thin f_1$*],
      ),
      table.hline(stroke: 0.5pt),
      [Tekis plita 15 mm (7--9-maşğ.)], [2100], [39.4], [2.61], [40.7], [71.6], [talaba töldiradi],
      [Tekis plita 25.5 mm], [3570], [193.4], [4.43], [8.3], [150.3], [talaba töldiradi],
      [U-profil, optimum (8 / 30.24)], [1604], [166.4], [1.99], [9.6], [150.0], [—],
      [U-profil, yaxlitlangan (8 / 31)], [1616], [176.4], [2.01], [9.1], [154.4], [talaba töldiradi],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Asos variantlarining soliştirma natijalari (analitik hisob)],
) <tab-compare>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: 4,
      align: center + horizon,
      stroke: none,
      inset: (x: 8pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header([*Natija $y$*], [*Qiymati*], [*$S_(y, t)$*], [*$S_(y, h)$*]),
      table.hline(stroke: 0.5pt),
      [Massa $m$], [1.992 kg], [0.70], [0.30],
      [Salqilik $f$], [9.63 µm], [$-0.64$], [$-2.36$],
      [Xususiy çastota $f_1$], [150.0 Hz], [0.28], [1.16],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Optimal nuqtadagi normallaştirilgan sezgirlik koeffitsientlari],
) <tab-sens>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (auto, auto, auto, auto, auto, auto, auto),
      align: center + horizon,
      stroke: none,
      inset: (x: 5pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        table.cell(rowspan: 2)[*$d times p$ \ \[mm\]*],
        table.cell(rowspan: 2)[*$Delta x$ \ \[µm\]*],
        table.cell(colspan: 2)[*I sikl: 300 mm*],
        table.cell(colspan: 3)[*II sikl: 20 mm*],
        [*$t_m$ \[ms\]*], [*$T_"rms"$ \[N·m\]*], [*$t_m$ \[ms\]*], [*$a$ \[m/s²\]*], [*$T_"rms"$ \[N·m\]*],
      ),
      table.hline(stroke: 0.5pt),
      [12 × 5], [0.5], [1205], [0.14], [84.9], [51.3], [0.44],
      [12 × 10], [1.0], [607], [0.21], [*46.9*], [72.9], [0.58],
      [16 × 5], [0.5], [1207], [0.17], [87.1], [35.0], [0.53],
      [16 × 10], [1.0], [609], [0.24], [49.9], [50.5], [0.64],
      [16 × 16], [1.6], [*388*], [0.33], [*46.4*], [37.4], [0.64],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Standart uzatma variantlarining harakat sikllari böyiça soliştirmasi (barça variantlarda $T_"pk" <= T_max$)],
) <tab-variants>

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // x: p, 0..30 mm (1 birlik = 3 mm); y: log10(t_m), 20..5000 ms
    let fx(p) = p / 3
    let fy(t) = (calc.log(t, base: 10) - calc.log(20, base: 10)) * 3.2
    let ps = (2, 3, 4, 5, 6, 8, 10, 12, 14, 16, 20, 25, 30)
    let t1 = (3004.3, 2004.5, 1504.6, 1204.9, 1005.2, 755.9, 606.9, 508.0, 438.0, 386.0, 314.8, 260.8, 228.1)
    let t2 = (204.3, 137.8, 104.6, 84.9, 71.8, 55.9, 46.9, 41.4, 39.8, 40.3, 44.2, 47.4, 50.9)
    for t in (20, 50, 100, 200, 500, 1000, 2000, 5000) {
      line((0, fy(t)), (10, fy(t)), stroke: 0.3pt + luma(220))
      content((-0.1, fy(t)), text(size: 7.5pt)[#t], anchor: "east")
    }
    for p in range(0, 31, step: 5) {
      line((fx(p), 0), (fx(p), fy(5000)), stroke: 0.3pt + luma(220))
      content((fx(p), -0.1), text(size: 7.5pt)[#p], anchor: "north")
    }
    line((0, 0), (10.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    content((10.6, 0), text(size: 9pt)[$p$ \[mm\]], anchor: "west")
    line((0, 0), (0, fy(5000) + 0.4), stroke: 1pt, mark: (end: ">", fill: black))
    content((0, fy(5000) + 0.45), text(size: 9pt)[$t_m$ \[ms\]], anchor: "south")
    line(..ps.zip(t1).map(((p, t)) => (fx(p), fy(t))), stroke: 1.5pt + pblue)
    line(..ps.zip(t2).map(((p, t)) => (fx(p), fy(t))), stroke: 1.5pt + orange.darken(20%))
    line((fx(12.6), 0), (fx(12.6), fy(5000)), stroke: (paint: red.darken(10%), thickness: 0.8pt, dash: "dashed"))
    content((fx(12.6) + 0.1, fy(3500)), text(size: 8pt, fill: red.darken(20%))[$p_"opt" = 12.6$ mm], anchor: "west")
    circle((fx(14), fy(39.8)), radius: 0.11, fill: red, stroke: none)
    content((fx(6), fy(1100)), text(size: 8pt, fill: pblue)[I sikl (300 mm)], anchor: "west")
    content((fx(19), fy(30)), text(size: 8pt, fill: orange.darken(30%))[II sikl (20 mm)], anchor: "west")
  }),
  caption: [Harakat vaqtining vint qadamiga boğliqligi ($d = 12$ mm, logarifmik masştab)],
) <fig-lead>

= Namunaviy hisob-kitoblar va tahlil

== Asos profilining optimal yeçimi

SLSQP usuli 3 xil boşlanğiç nuqtadan bir xil yeçimga yaqinlaşadi: $t = 8.00$ mm, $h = 30.24$ mm, $m = 1.992$ kg. Optimal nuqtada ikki çeklov aktiv: pastki çegara $t = 8$ mm va çastota çeklovi $f_1 = 150$ Hz. Salqilik çeklovi esa aktiv emas ($f = 9.63 < 10$ µm). Demak, bu masalada hal qiluvçi talab --- dinamik bikrlik.

Optimal profil 9-maşğulotdagi tekis plita (15 mm) bilan soliştirilganda:
- kesim yuzasi 24 % kiçik ($1604$ va $2100 "mm"^2$);
- inersiya momenti 4.2 marta katta;
- massa 2.61 kg dan 1.99 kg gaça kamaygan;
- salqilik 4.2 marta, xususiy çastota 2.1 marta yaxşilangan.

9-maşğulotda taklif qilingan 25.5 mm li tekis plita esa öşa talablarni 4.43 kg massa bilan bajaradi. Optimal profil undan 55 % yengil. Yaxlitlangan variant ($h = 31$ mm) ikki talabni ham zaxira bilan qanoatlantiradi: $f = 9.1$ µm, $f_1 = 154.4$ Hz.

== Sezgirlik va Pareto tahlili

@tab-sens körsatadiki, devor balandligi $h$ ni 1 % ga oşiriş çastotani 1.16 % ga oşiradi, massani esa atigi 0.30 % ga oşiradi. Plita qalinligi $t$ uçun esa bu nisbat teskari: massa 0.70 %, çastota 0.28 % oşadi. Massa birligiga töğri keladigan samaradorlik $h$ uçun ($1.16 \/ 0.30 approx 3.9$) $t$ ga nisbatan ($0.28 \/ 0.70 = 0.4$) qariyb 10 marta yuqori. Şu sababli optimizator materialni neytral öqdan uzoqroqqa, devorlarga ötkazadi va $t$ ni pastki çegaraga olib boradi. Bu "materialni egiliş kuçlanişi katta bölgan joyga joylaş" degan konstruktiv qoidaning matematik tasdiğidir.

Pareto front qiyaligi (@fig-pareto) 150 Hz atrofida:

$ (Delta m) / (Delta f_1) approx (2.077 - 1.992) / (175 - 150) approx 0.0034 "kg/Hz" $

Yaʼni çastota talabini 10 Hz ga oşiriş taxminan 34 g qöşimça massa talab qiladi. Bu qiymat KKT şartidagi Lagranj köpaytuvçisining amaliy maʼnosidir. Tekis plitalar Pareto frontdan ançagina yuqorida yotadi, yaʼni ular ustunlik qilinadigan (_dominated_) yeçimlardir.

== Uzatma qadamini tanlaş

Inersiyalar moslaşgan qadam ($J_0 = J_m + J_c + J_v = 2.54 times 10^(-5) "kg" dot "m"^2$):

$ p_"opt" = 2 pi sqrt((2.54 times 10^(-5)) / 6.35) approx 0.0126 "m" = 12.6 "mm" $

@fig-lead da ikki xil xatti-harakat körinadi:
- *I sikl (300 mm):* harakat asosan tezlik çeklovi ostida ötadi ($t_m approx s \/ v_max$). Şu sababli vaqt qadam oşgan sari kamayaveradi. Bu siklda $16 times 16$ variant eng tez (388 ms): $12 times 10$ dan 36 % qisqa.
- *II sikl (20 mm):* qisqa masofada tezlanişga erişiş muhim. Kiçik qadamlarda yana tezlik çeklovi, $p > 12$ mm da esa qiziş çeklovi ($T_"rms" = T_n$) aktiv böladi. Optimum $p approx 14$ mm atrofida, $p_"opt"$ ga yaqin.

Standart variantlar orasida II sikl uçun $12 times 10$ (46.9 ms) va $16 times 16$ (46.4 ms) deyarli teng. Lekin $12 times 10$ variantda moment böyiça zaxira bor ($T_"rms" = 0.58 < 0.64$), rezolyutsiya yaxşiroq (1.0 µm) va vint yengilroq. Şu sababli olib-qöyiş sikli uçun $12 times 10$, uzoq yuriş sikli uçun $16 times 16$ tavsiya etiladi. Bu misol optimal konstruktiv parametr modulning özigagina emas, balki uning işlatiliş sikliga ham boğliq ekanini körsatadi.

Eslatma: hisobda tezlaniş faqat dvigatel momenti bilan çeklangan ($a$ 35--73 m/s² gaça yetadi). Haqiqiy loyihada foydali yukni mahkamlaş va karetka bloklari böyiça ham tezlaniş çeklovi (masalan, $a <= 30$ m/s²) qöşilişi kerak. Bunda qisqa sikldagi variantlar orasidagi farq kamayadi.

= Nazorat savollari

+ Optimallaştiriş masalasining asosiy elementlari (loyiha özgaruvçilari, maqsad funksiyasi, çeklovlar) nimalardan iborat?
+ Aktiv çeklov nima? Lagranj köpaytuvçisining amaliy maʼnosini tuşuntiring.
+ Gradient va gradientsiz optimallaştiriş usullarining afzalliklari va kamçiliklari nimada?
+ Pareto front nima va u $epsilon$-çeklov usuli bilan qanday quriladi?
+ Normallaştirilgan sezgirlik koeffitsienti qanday hisoblanadi va undan qanday konstruktiv xulosa çiqariladi?
+ Nima uçun U-profil bir xil massada tekis plitadan ança bikr?
+ Inersiyalar moslaşuvi nima? $p_"opt"$ formulasini keltirib çiqaring.
+ Nima uçun uzoq va qisqa harakat sikllari uçun optimal vint qadami har xil böladi?
+ Örtaça kvadratik moment qanday hisoblanadi va u nima uçun çeklov sifatida qöllaniladi?
+ Topologik optimallaştiriş natijasini töğridan-töğri işlab çiqarişga berib bölmasligining sababi nimada?
