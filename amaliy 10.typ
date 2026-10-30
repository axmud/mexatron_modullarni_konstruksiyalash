// ============================================================
//  Mexatron modullarni konstruksiyalaş — FEM modeli — amaliy maşğulot — Typst versiyasi
//  Kompilyatsiya: typst compile amaliy_10.typ
// ============================================================

#import "@preview/cetz:0.4.2"

#let headingblue = rgb(20, 50, 120)

#set document(title: "Mexatron modul uçun FEM modeli yaratiş")
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
  #text(size: 20pt, weight: "bold", fill: headingblue)[AMALIYOT MAŞĞULOTI №10]
  #v(0.4cm)
  #text(
    size: 14pt,
    weight: "bold",
  )[Mavzu: Mexatron modul uçun FEM modeli yaratiş]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Işning maqsadi

*Maşğulotning maqsadi:* mexatron modulning çekli elementlar usuli (FEM) asosidagi hisobiy modelini yaratiş bosqiçlarini örganiş. 7--9-maşğulotlarda loyihalangan çiziqli modul misolida quyidagi könikmalarni hosil qiliş:
- Python yordamida bir ölçamli tösin elementlaridan iborat FEM dasturini yozib, uni analitik yeçim bilan tekşiriş (verifikatsiya);
- 3D CAD modelini FEM uçun soddalaştiriş va idealizatsiya qiliş;
- element turlari, tör, kontaktlar va çegaraviy şartlarni asosli tanlaş;
- modal tahlil bajariş;
- FEM natijalarini 6-tajribadagi ölçaş natijalari bilan tasdiqlaş (validatsiya).

= Dasturiy va texnik taʼminot

+ *CAD/FEA tizimi:* SolidWorks Simulation (Frequency moduli), Autodesk Inventor Stress Analysis (Modal) yoki bepul muqobil sifatida FreeCAD FEM (CalculiX hal qiluvçisi bilan).
+ *Python (NumPy, SciPy):* bir ölçamli FEM dasturi uçun (@lst-fem).
+ *Dastlabki maʼlumotlar:* 7-maşğulotdagi modul modeli va parametrlari, 8-maşğulotdagi tayanç yiğmasi, 9-maşğulotdagi hisobiy sxemalar, 6-tajribadagi rezonans çastotalari.

= FEM modelini yaratişning nazariy asoslari

== Çekli elementlar usulining mohiyati

FEM da uzluksiz jism çekli sondagi elementlarga bölinadi. Elementlar bir-biri bilan tugunlarda tutaşadi. Har bir element içidagi köçiş maydoni tugun köçişlari orqali şakl funksiyalari yordamida ifodalanadi:

$ u(x) approx bold(N)(x) thin bold(d)_e $ <eq-shape>

bunda $bold(N)$ --- şakl funksiyalari matritsasi, $bold(d)_e$ --- element tugunlarining köçişlar vektori. Har bir element uçun bikrlik va massa matritsalari $bold(k)_e$, $bold(m)_e$ hisoblanadi. Söng ular umumiy matritsalarga yiğiladi (_assembly_). Statik masala çiziqli tenglamalar tizimiga, modal masala esa umumlaşgan xususiy qiymatlar masalasiga keltiriladi:

$ bold(K) bold(d) = bold(F), quad (bold(K) - omega^2 bold(M)) bold(phi) = bold(0) $ <eq-fem>

bunda $omega_i$ --- xususiy çastotalar, $bold(phi)_i$ --- tebraniş şakllari (modalar).

Eyler--Bernulli tösin elementi ikki tugunga ega. Har bir tugunda ikkita erkinlik darajasi bor: salqilik $w$ va buriliş burçagi $theta$. Uning bikrlik matritsasi:

$
  bold(k)_e = (E I) / L_e^3 mat(
    12, 6 L_e, -12, 6 L_e;
    6 L_e, 4 L_e^2, -6 L_e, 2 L_e^2;
    -12, -6 L_e, 12, -6 L_e;
    6 L_e, 2 L_e^2, -6 L_e, 4 L_e^2
  )
$ <eq-ke>

Kelişilgan (_consistent_) massa matritsasi ham öşa kubik şakl funksiyalaridan hosil qilinadi va $rho A L_e \/ 420$ köpaytuvçiga ega (@lst-fem).

== Element turlari

Element turini tanlaş detalning şakliga va kerakli natijaga boğliq:
- *1D tösin elementlari:* uzunligi kesim ölçamidan köp marta katta detallar uçun (vallar, vintlar, sterjenlar). Ular eng kam hisob talab qiladi.
- *2D qobiq elementlari* (_shell_): yupqa devorli detallar uçun (listlar, korpus devorlari, profillar).
- *3D hajmiy elementlar:* murakkab şaklli massiv detallar uçun. Tetraedrlar (tet4, tet10) avtomatik tör uçun qulay, geksaedrlar (hex8, hex20) esa aniqroq, lekin tör qurişi qiyinroq.

Çiziqli tet4 elementlari egilişda haddan taşqari bikr böladi ("qulflaniş" effekti). Şuning uçun egilişga işlaydigan detallarda kvadratik tet10 elementlari qöllaniladi. Yupqa devor bölgan joyda qalinlik böyiça kamida 2 ta kvadratik element bölişi kerak.

== Modelni soddalaştiriş va idealizatsiya

CAD modeli konstruktorlik hujjatlari uçun yaratiladi va FEM uçun ortiqça mayda detallarga ega. Hisobiy model quyidagiça tayyorlanadi:
- *soddalaştiriş* (_defeaturing_): natijaga taʼsir qilmaydigan mayda elementlar olib taşlanadi;
- *idealizatsiya:* içki tuzilişi muhim bölmagan komponentlar (dvigatel, foydali yuk) massa va inersiyaga ega nuqtaviy massa bilan almaştiriladi. Ular detalga qattiq (RBE2) yoki taqsimlovçi (RBE3) boğlanişlar orqali ulanadi. Podşipniklar va elastik elementlar prujina elementlari bilan, boltlar esa konnektorlar bilan ifodalanadi;
- *simmetriyadan foydalaniş:* geometriya va yuklama simmetrik bölsa, modelning yarmi yoki çoragi hisoblanadi (modal tahlilda bunda nosimmetrik modalar yöqoladi).

== Kontaktlar va çegaraviy şartlar

Yiğmadagi detallar orasidagi boğlaniş FEM natijasiga katta taʼsir qiladi:
- *birlaşgan* (_bonded_) kontakt detallarni yaxlit jismday birlaştiradi va bikrlikni oşirib yuboriş xavfini tuğdiradi;
- *kirib ketmaslik* (_no penetration_) kontakti realroq, lekin masalani noçiziqli qiladi va modal tahlilda qöllanilmaydi.

Çegaraviy şartlar jismning qattiq jism sifatidagi barça 6 ta erkinlik darajasini yöqotişi kerak. Aks holda statik masala yeçilmaydi. Ortiqça mahkamlaş esa konstruksiyani haqiqiydan bikrroq qilib körsatadi.

Modelning töğriligini tekşirişning oddiy usuli --- *erkin-erkin modal tahlil*. Bunda hiçqanday mahkamlaş berilmaydi. Töğri yiğilgan modelda 6 ta qattiq jism modasi ($f approx 0$) çiqadi. Agar ular 6 tadan köp bölsa, demak yiğmada boğlanmagan detal bor.

== Verifikatsiya va validatsiya

*Verifikatsiya* --- model tenglamalari töğri yeçilganini tekşiriş ("masalani töğri yeçyapmizmi?"). U analitik yeçimlar bilan soliştiriş va tör yaqinlaşuvi orqali bajariladi. *Validatsiya* --- modelning real obʼyektni töğri ifodalaşini tekşiriş ("töğri masalani yeçyapmizmi?"). U tajriba natijalari bilan soliştiriş orqali bajariladi. Nisbiy xatolik:

$ epsilon = abs(f_"FEM" - f_"ref") / f_"ref" dot 100 % $ <eq-err>

Analitik soliştiriş uçun bir uçi qattiq mahkamlangan, ikkinçi uçi şarnirli tösinning birinçi xususiy çastotasi:

$ f_1 = (beta_1 l)^2 / (2 pi l^2) sqrt((E I) / (rho A)), quad beta_1 l = 3.9266 $ <eq-f1>

Ikki uçi şarnirli tösinning örtasiga nuqtaviy massa $m$ qöyilganda Reley usuli böyiça taxminiy çastota ($m_p$ --- tösin massasi):

$ f_1 approx 1 / (2 pi) sqrt((48 E I \/ L^3) / (m + 0.49 m_p)) $ <eq-rayleigh>

#figure(
  cetz.canvas(length: 0.92cm, {
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
    let arr(..pts) = line(..pts, stroke: 1pt + dslate, mark: (end: ">", fill: dslate))
    let xs = (0, 3.4, 6.8, 10.2, 13.6)
    let tops = (
      [*CAD modeli*],
      [*Soddalaştiriş va* \ *idealizatsiya*],
      [*Material,* \ *elementlar, tör*],
      [*Kontaktlar va* \ *çegaraviy şartlar*],
      [*Yeçiş* \ (statik / modal)],
    )
    for (q, x) in xs.enumerate() {
      blk((x, 1.2), 2.8, 1.1, if q < 2 { yellow.lighten(80%) } else { blue.lighten(88%) }, tops.at(q))
      if q < 4 { arr((x + 1.4, 1.2), (xs.at(q + 1) - 1.4, 1.2)) }
    }
    blk((13.6, -1.0), 2.8, 1.1, green.lighten(85%))[*Postprotsessing* \ (modalar, epyuralar)]
    blk((8.5, -1.0), 4.4, 1.1, orange.lighten(80%))[*Verifikatsiya* (analitik, tör) \ *Validatsiya* (tajriba)]
    blk((3.4, -1.0), 2.8, 1.1, purple.lighten(88%))[*Işonçli model* \ (loyihalaş uçun)]
    arr((13.6, 0.65), (13.6, -0.45))
    arr((12.2, -1.0), (10.7, -1.0))
    arr((6.3, -1.0), (4.8, -1.0))
    line(
      (8.5, -1.55),
      (8.5, -2.2),
      (16.0, -2.2),
      (16.0, 1.2),
      (15.0, 1.2),
      stroke: (paint: red.darken(10%), thickness: 1pt, dash: "dashed"),
      mark: (end: ">", fill: red.darken(10%)),
    )
    content((12.3, -2.25), text(size: 7.5pt, fill: red.darken(20%))[mos kelmasa: modelni tuzatiş], anchor: "north")
  }),
  caption: [FEM modelini yaratiş, tekşiriş va tasdiqlaş bosqiçlari],
) <fig-flow>

= Amaliy maşğulotni bajariş tartibi

== 1-topşiriq: bir ölçamli FEM dasturini yoziş va verifikatsiya qiliş

+ @lst-fem dagi dasturni Python muhitida yozing. Dastur Eyler--Bernulli tösin elementlarining bikrlik va massa matritsalarini hosil qiladi, ularni yiğadi va çegaraviy şartlarni qöllaydi.
+ Şarik-vintli vintni (@fig-screw) qattiq--şarnir sxemada ($d_r = 9.9$ mm, $l_b = 360$ mm) modellang. Elementlar sonini 2, 4, 8, 16, 32 qilib birinçi xususiy çastotani hisoblang. Natijani (@eq-f1) analitik yeçim bilan solişting (@tab-conv).
+ Hisoblangan çastotani aylaniş çastotasiga ($n = 60 f$) aylantiring va 7-maşğulotdagi katalog formulasi bilan solişting.
+ Asos plitasini ikki uçi şarnirli tösin deb modellang. Örtadagi karetka uçun statik salqilikni (9-maşğulot) va nuqtaviy massa bilan birinçi xususiy çastotani hisoblang.

#figure(
  ```python
  import numpy as np
  from scipy.linalg import eigh

  def beam_fem(L, E, I, rhoA, n_el, fixed_dofs):
      """Eyler–Bernulli tösinining bikrlik (K) va massa (M) matritsalari."""
      Le = L / n_el
      k = E * I / Le**3 * np.array([[12, 6*Le, -12, 6*Le],
                                    [6*Le, 4*Le**2, -6*Le, 2*Le**2],
                                    [-12, -6*Le, 12, -6*Le],
                                    [6*Le, 2*Le**2, -6*Le, 4*Le**2]])
      m = rhoA * Le / 420 * np.array([[156, 22*Le, 54, -13*Le],
                                      [22*Le, 4*Le**2, 13*Le, -3*Le**2],
                                      [54, 13*Le, 156, -22*Le],
                                      [-13*Le, -3*Le**2, -22*Le, 4*Le**2]])
      ndof = 2 * (n_el + 1)                  # har tugunda: w va θ
      K, M = np.zeros((ndof, ndof)), np.zeros((ndof, ndof))
      for e in range(n_el):                  # yiğiş (assembly)
          idx = slice(2 * e, 2 * e + 4)
          K[idx, idx] += k
          M[idx, idx] += m
      free = np.setdiff1d(np.arange(ndof), fixed_dofs)
      return K, M, free

  # Şarik-vintli vint: d_r = 9.9 mm, l_b = 360 mm, qattiq–şarnir (SI birliklar)
  d, L, E, rho = 9.9e-3, 0.360, 2.1e11, 7850.0
  I, A = np.pi * d**4 / 64, np.pi * d**2 / 4
  for n_el in (2, 4, 8, 16, 32):
      n_last = 2 * n_el                      # öng uçdagi w erkinlik darajasi
      K, M, free = beam_fem(L, E, I, rho * A, n_el, [0, 1, n_last])
      w2, _ = eigh(K[np.ix_(free, free)], M[np.ix_(free, free)])
      f1 = np.sqrt(w2[0]) / (2 * np.pi)
      print(f"n_el = {n_el:2d}: f1 = {f1:7.2f} Hz, n_cr = {60 * f1:6.0f} ayl/min")

  # Asos plitasi: şarnir–şarnir, örtada karetka (F = 62.3 N, m = 6.35 kg)
  b, t, L2, E2 = 0.140, 0.015, 0.440, 6.9e10
  K, M, free = beam_fem(L2, E2, b * t**3 / 12, 2700 * b * t, 8, [0, 16])
  Kf = K[np.ix_(free, free)]
  F = np.zeros(18); F[8] = -62.3            # örta tugun (4-tugun) w erk. darajasi
  u = np.zeros(18); u[free] = np.linalg.solve(Kf, F[free])
  M[8, 8] += 6.35                           # karetka + yuk — nuqtaviy massa
  w2, _ = eigh(Kf, M[np.ix_(free, free)])
  f1 = np.sqrt(w2[0]) / (2 * np.pi)
  print(f"plita: f = {-u[8] * 1e6:.1f} µm, f1 = {f1:.1f} Hz")
  ```,
  caption: [Eyler--Bernulli tösin elementlari asosidagi bir ölçamli FEM dasturi],
) <lst-fem>

Dastur natijasi:

```text
n_el =  2: f1 =  244.62 Hz, n_cr =  14677 ayl/min
n_el =  4: f1 =  242.53 Hz, n_cr =  14552 ayl/min
n_el =  8: f1 =  242.39 Hz, n_cr =  14543 ayl/min
n_el = 16: f1 =  242.38 Hz, n_cr =  14543 ayl/min
n_el = 32: f1 =  242.38 Hz, n_cr =  14543 ayl/min
plita: f = 40.7 µm, f1 = 71.6 Hz
```

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // a) Tösin elementi
    line((0, 4.2), (4, 4.2), stroke: 2pt + pblue)
    for (x, i) in ((0, 1), (4, 2)) {
      circle((x, 4.2), radius: 0.12, fill: white, stroke: 1pt + dslate)
      line((x, 4.2), (x, 5.2), stroke: 1pt + red.darken(10%), mark: (end: ">", fill: red.darken(10%)))
      content((x + 0.1, 5.1), text(size: 8pt, fill: red.darken(20%))[$w_#i$], anchor: "west")
      arc((x + 0.5, 4.2), start: 0deg, stop: 150deg, radius: 0.5, stroke: 1pt + orange.darken(20%), mark: (
        end: ">",
        fill: orange.darken(20%),
      ))
      content((x + 0.6, 4.35), text(size: 8pt, fill: orange.darken(30%))[$theta_#i$], anchor: "west")
    }
    content((2, 4.05), text(size: 8pt)[$E I, thin rho A, thin L_e$], anchor: "north")
    content((-0.3, 5.6), text(size: 9pt, weight: "bold")[a)], anchor: "west")

    // b) Diskret vint va birinçi moda
    content((5.7, 5.6), text(size: 9pt, weight: "bold")[b)], anchor: "west")
    let x0 = 6.6
    let Lx = 9.0
    // qattiq mahkamlaş
    line((x0, 3.4), (x0, 5.0), stroke: 1.5pt + dslate)
    for j in range(0, 7) {
      let y = 3.45 + j * 0.25
      line((x0, y), (x0 - 0.3, y - 0.25), stroke: 0.5pt + dslate)
    }
    // şarnirli tayanç
    let xe = x0 + Lx
    line((xe, 4.2), (xe - 0.3, 3.6), (xe + 0.3, 3.6), close: true, stroke: 1pt + dslate, fill: white)
    line((xe - 0.45, 3.6), (xe + 0.45, 3.6), stroke: 1pt + dslate)
    // elementlar (n = 8) va tugunlar
    line((x0, 4.2), (xe, 4.2), stroke: 2pt + luma(150))
    for j in range(0, 9) {
      circle((x0 + Lx * j / 8, 4.2), radius: 0.08, fill: dslate, stroke: none)
    }
    // birinçi moda şakli (16 elementli FEM natijasi)
    let phi = (
      0.0,
      0.037,
      0.134,
      0.272,
      0.432,
      0.596,
      0.747,
      0.873,
      0.96,
      1.0,
      0.989,
      0.925,
      0.811,
      0.652,
      0.456,
      0.235,
      0.0,
    )
    let pts = phi.enumerate().map(((j, v)) => (x0 + Lx * j / 16, 4.2 + 1.1 * v))
    line(..pts, stroke: 1.5pt + red.darken(10%))
    content((x0 + Lx * 0.56, 5.4), text(size: 8pt, fill: red.darken(20%))[1-moda: $f_1 = 242.4$ Hz], anchor: "south")
    line((x0, 2.9), (xe, 2.9), stroke: 0.8pt, mark: (start: ">", end: ">", fill: black, scale: 0.6))
    content((x0 + Lx / 2, 2.85), text(size: 8pt)[$l_b = 360$ mm, 8 ta element], anchor: "north")
  }),
  caption: [a) Eyler--Bernulli tösin elementining erkinlik darajalari; b) vintning qattiq--şarnir FEM modeli va birinçi tebraniş şakli],
) <fig-screw>

== 2-topşiriq: 3D FEM modelini tayyorlaş

+ 7-maşğulotdagi modul yiğmasining nusxasini oling va @tab-defeat dagi qoidalar böyiça soddalaştiring. Kuçlaniş toplanadigan joylardagi galtellarni saqlang (9-maşğulot).
+ Komponentlarni @tab-ideal böyiça idealizatsiya qiling: servodvigatel va foydali yukni nuqtaviy massalar bilan almaştiring (@fig-ideal). Vintni tösin elementi, podşipniklarni prujina elementlari bilan ifodalang.
+ Materiallarni bering. Asos plitasi uçun kvadratik tet10 elementlari bilan tör quring: global element ölçami 5 mm, qalinlik böyiça kamida 3 ta element, karetka bloklari tegib turgan joylarda mahalliy maydalaş.
+ Asos plitasini 9-maşğulotdagi hisobiy sxema böyiça mahkamlang: ikki çetki tayanç çiziği böyiça şarnirli tayanç.

== 3-topşiriq: modal tahlil

+ Avval *erkin-erkin* modal tahlilni bajaring va 6 ta qattiq jism modasi ($f < 1$ Hz) çiqqanini tekşiring. Agar ular 6 tadan köp bölsa, boğlanmagan komponentni toping va tuzating.
+ Mahkamlaş bilan dastlabki 6 ta xususiy çastotani hisoblang. Har bir moda şaklini animatsiyada körib, tavsiflang va modal massa uluşini yozib oling.
+ Hisobni relslarning ikki xil modeli uçun takrorlang: (A) relslar faqat massa sifatida; (B) relslar plita bilan birlaşgan (_bonded_). Natijalarni @tab-modes ga kiriting.
+ (A) variantdagi birinçi moda çastotasini 1-topşiriqdagi tösin modeli natijasi bilan solişting.

== 4-topşiriq: modelni tajriba bilan tasdiqlaş (validatsiya)

+ 6-tajribadagi ikki massali buralma stendning FEM modelini yarating:
  - dvigatel tomoni va yuklama diskini hajmiy elementlar bilan modellang (inersiya momentlari $J_m = 2.0 times 10^(-4)$, $J_L = 6.0 times 10^(-4) "kg" dot "m"^2$ ga moslang);
  - elastik muftani buralma prujina konnektori ($k_1 = 12$ yoki $k_2 = 24 "N" dot "m/rad"$) bilan ifodalang;
  - vallarni podşipnik konnektorlari orqali faqat aylanişga ruxsat beriladigan qilib mahkamlang.
+ Ikki holat uçun modal tahlil bajaring: dvigatel vali erkin (rezonans $f_r$) va qulflangan (antirezonans $f_"ar"$). Natijalarni 6-tajribadagi ölçaş natijalari bilan (@eq-err) böyiça solişting (@tab-valid).

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // Asos plitasi
    rect((0, 0), (15, 0.6), fill: blue.lighten(88%), stroke: 1pt + dslate)
    for j in range(0, 25) {
      let x = 0.3 + j * 0.6
      line((x, 0.05), (x + 0.25, 0.55), stroke: 0.3pt + luma(150))
    }
    content((7.5, -0.15), text(size: 7.5pt)[asos plitasi: tet10, 5 mm], anchor: "north")
    // Şarnirli tayançlar
    let support(x) = {
      line((x, 0), (x - 0.3, -0.55), (x + 0.3, -0.55), close: true, stroke: 1pt + dslate, fill: white)
      line((x - 0.45, -0.55), (x + 0.45, -0.55), stroke: 1pt + dslate)
    }
    support(0.4)
    support(14.6)
    // Relslar
    rect((4.4, 0.6), (13.0, 0.9), fill: luma(200), stroke: 0.8pt + dslate)
    content((12.9, 0.95), text(size: 7pt)[relslar: (A) massa / (B) bonded], anchor: "south-east")
    // Tayanç korpuslari
    rect((3.0, 0.6), (3.8, 2.6), fill: green.lighten(85%), stroke: 0.8pt + dslate)
    rect((13.4, 0.6), (14.2, 2.6), fill: green.lighten(85%), stroke: 0.8pt + dslate)
    // Vint — tösin elementi
    line((3.4, 1.9), (13.8, 1.9), stroke: 2pt + pblue)
    for j in range(0, 14) {
      circle((3.4 + j * 0.8, 1.9), radius: 0.07, fill: pblue, stroke: none)
    }
    content((10.2, 1.95), text(size: 7.5pt, fill: pblue)[vint: tösin elementlari], anchor: "south")
    // Podşipnik prujinalari
    let spring(x, y0, y1) = {
      let pts = ((x, y0),)
      for j in range(0, 6) {
        pts.push((x + if calc.rem(j, 2) == 0 { 0.15 } else { -0.15 }, y0 + (j + 0.5) * (y1 - y0) / 6))
      }
      pts.push((x, y1))
      line(..pts, stroke: 0.8pt + red.darken(10%))
    }
    spring(3.4, 1.0, 1.85)
    spring(13.8, 1.0, 1.85)
    content((3.0, 1.4), text(size: 7pt, fill: red.darken(20%))[$k_"pod"$], anchor: "east")
    // Karetka
    rect((7.4, 0.9), (9.8, 1.5), fill: purple.lighten(80%), stroke: 0.8pt + dslate)
    rect((7.0, 2.3), (10.2, 2.7), fill: purple.lighten(85%), stroke: 0.8pt + dslate)
    rect((8.2, 1.5), (9.0, 2.3), fill: purple.lighten(65%), stroke: 0.8pt + dslate)
    // Foydali yuk — nuqtaviy massa (RBE3)
    circle((8.6, 4.0), radius: 0.3, fill: dslate, stroke: none)
    content((8.95, 4.0), text(size: 8pt)[$m_y = 5$ kg (RBE3)], anchor: "west")
    for x in (7.2, 8.0, 9.2, 10.0) {
      line((8.6, 4.0), (x, 2.7), stroke: (paint: dslate, thickness: 0.6pt, dash: "dashed"))
    }
    // Servodvigatel — nuqtaviy massa (RBE2)
    rect((1.0, 0.6), (1.4, 3.0), fill: blue.lighten(75%), stroke: 0.8pt + dslate)
    circle((-0.4, 2.0), radius: 0.3, fill: dslate, stroke: none)
    content((-0.4, 2.45), text(size: 8pt)[$m_m$, $J_m$ (RBE2)], anchor: "south")
    for y in (0.9, 1.6, 2.4, 2.9) {
      line((-0.4, 2.0), (1.0, y), stroke: (paint: dslate, thickness: 0.6pt, dash: "dashed"))
    }
  }),
  caption: [Çiziqli modulning idealizatsiyalangan FEM modeli],
) <fig-ideal>

= Natijalar jadvallari

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
      table.header([*Element*], [*Amal*], [*Asos*]),
      table.hline(stroke: 0.5pt),
      [M3--M6 rezbali teşiklar],
      [rezbasiz teşik yoki olib taşlaş],
      [rezba geometriyasi global bikrlikka taʼsir qilmaydi],
      [Faskalar, $r <= 1$ mm yumaloqlaşlar],
      [olib taşlaş (kuçlaniş zonasidan taşqarida)],
      [tör elementlari sonini keskin kamaytiradi],
      [Kuçlaniş zonasidagi galtellar], [*saqlaş*], [singulyarlikning oldini oladi (9-maşğulot)],
      [Yozuvlar, belgilar, logotiplar], [olib taşlaş], [mexanik ahamiyati yöq],
      [Rels profilidagi ariqçalar], [töğri törtburçak kesim bilan almaştiriş], [kesim inersiya momentini saqlaş kerak],
      [Podşipnikning içki tuzilişi], [prujina elementi], [faqat bikrligi muhim],
      table.hline(stroke: 1pt),
    )
  },
  caption: [CAD modelini FEM uçun soddalaştiriş qoidalari],
) <tab-defeat>

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
      table.header([*Komponent*], [*FEM dagi ifodasi*], [*Material / parametrlar*]),
      table.hline(stroke: 0.5pt),
      [Asos plitasi], [3D, tet10, 5 mm (mahalliy 2 mm)], [AW-6061: $E = 69$ GPa, $rho = 2700 "kg/m"^3$],
      [Profil relslar], [3D (B) yoki taqsimlangan massa (A)], [pölat: $E = 210$ GPa],
      [Karetka plitasi va bloklari], [3D, tet10], [AW-6061, pölat],
      [Foydali yuk], [nuqtaviy massa, RBE3], [$m_y = 5$ kg],
      [Servodvigatel], [nuqtaviy massa, RBE2 (flanesga)], [$m_m = 1.2$ kg, $J_m = 1.8 times 10^(-5) "kg" dot "m"^2$],
      [Şarik-vintli vint], [tösin elementlari], [Ø9.9 mm, pölat],
      [Podşipniklar], [prujina elementlari], [radial va öq bikrligi --- katalogdan],
      [Boltlar], [bolt konnektorlari], [M5, dastlabki taranglaş 5 kN],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Modul komponentlarining FEM da idealizatsiyalanişi],
) <tab-ideal>

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
      table.header([*Elementlar soni*], [*Erkinlik darajalari*], [*$f_1$ \[Hz\]*], [*Xatolik $epsilon$ \[%\]*]),
      table.hline(stroke: 0.5pt),
      [2], [3], [244.62], [0.92],
      [4], [7], [242.53], [0.062],
      [8], [15], [242.39], [0.004],
      [16], [31], [242.38], [$< 0.001$],
      [32], [63], [242.38], [$< 0.001$],
      table.hline(stroke: 0.5pt),
      table.cell(colspan: 2)[Analitik yeçim (@eq-f1)], [242.38], [—],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Vintning birinçi xususiy çastotasi: tösin FEM ning yaqinlaşuvi],
) <tab-conv>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (auto, auto, auto, 1fr),
      align: (center + horizon, center + horizon, center + horizon, left + horizon),
      stroke: none,
      inset: (x: 6pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*Moda*], [*(A) relslar --- massa \ $f$ \[Hz\]*], [*(B) relslar --- bonded \ $f$ \[Hz\]*], [*Moda şakli*]
      ),
      table.hline(stroke: 0.5pt),
      [1], [70.4], [148], [plitaning karetka bilan vertikal egilişi (Z, massa uluşi $approx 75 %$)],
      [2], [182], [265], [plitaning buralişi va karetkaning ağdarilişi],
      [3], [214], [231], [karetkaning relslar ustida ağdarilişi (bloklar bikrligi)],
      [4], [610], [690], [plitaning gorizontal egilişi (Y)],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Çiziqli modulning modal tahlili natijalari (namunaviy, karetka örta holatda)],
) <tab-modes>

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
      table.header(
        [*Holat (6-tajriba stendi)*],
        [*FEM \ \[Hz\]*],
        [*Nazariya \ \[Hz\]*],
        [*Tajriba \ \[Hz\]*],
        [*$epsilon$ (FEM--tajriba) \ \[%\]*],
      ),
      table.hline(stroke: 0.5pt),
      [$k_1$, dvigatel erkin (rezonans $f_r$)], [45.0], [45.02], [45.1], [0.2],
      [$k_1$, dvigatel qulflangan (antirezonans $f_"ar"$)], [22.5], [22.51], [22.4], [0.4],
      [$k_2$, dvigatel erkin (rezonans $f_r$)], [63.6], [63.66], [63.9], [0.5],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Buralma stend FEM modelini 6-tajriba natijalari bilan tasdiqlaş],
) <tab-valid>

= Namunaviy hisob-kitoblar va tahlil

== Vint modelining verifikatsiyasi

Vint uçun $I = pi d_r^4 \/ 64 approx 471.5 "mm"^4 = 4.715 times 10^(-10) "m"^4$, $A approx 76.98 "mm"^2$, $rho A = 7850 dot 76.98 times 10^(-6) approx 0.604 "kg/m"$. (@eq-f1) ga köra:

$
  f_1 = 3.9266^2 / (2 pi dot 0.36^2) sqrt((2.1 times 10^(11) dot 4.715 times 10^(-10)) / 0.604) \
  = 118.97 / (2 pi) dot 12.80 approx 242.4 "Hz"
$

FEM natijasi 8 ta element bilan analitik yeçimdan atigi 0.004 % ga farq qiladi (@tab-conv). Xatolik elementlar sonining törtinçi darajasiga teskari proporsional tez kamayadi: 2 ta elementdan 4 taga ötganda xatolik 15 marta kamaygan. Bu kubik şakl funksiyali tösin elementlarining yuqori aniqligini körsatadi.

== Katalog formulasi bilan soliştiriş

FEM böyiça nazariy kritik aylaniş çastotasi $n = 60 f_1 approx 14 thin 543$ ayl/min. 7-maşğulotdagi katalog formulasi esa $11 thin 535$ ayl/min beradi. Ularning nisbati:

$ (11 thin 535) / (14 thin 543) approx 0.79 $

Demak, katalog koeffitsienti $lambda_2 = 15.1$ ga 0.8 xavfsizlik koeffitsienti allaqaçon kiritilgan. Kiçik farq kataloglarda $E = 206$ GPa olinişi bilan boğliq. Bu misol FEM yoki analitik tekşiruv katalog formulalarining içki farazlarini oçib beriş imkonini berişini körsatadi.

== Asos plitasi modelining verifikatsiyasi

Tösin FEM ning statik natijasi ($40.7$ µm) 9-maşğulotdagi analitik qiymatga aynan teng. Buning sababi: kubik şakl funksiyalari tugunlarga qöyilgan kuçlarda Eyler--Bernulli nazariyasining aniq yeçimini beradi. Modal natijani (@eq-rayleigh) bilan tekşiramiz. Bunda $48 E I \/ L^3 approx 1.531 times 10^6 "N/m"$, plita massasi $m_p = 2700 dot 0.14 dot 0.015 dot 0.44 approx 2.49 "kg"$:

$ f_1 approx 1 / (2 pi) sqrt((1.531 times 10^6) / (6.35 + 0.49 dot 2.49)) approx 71.4 "Hz" $

FEM natijasi ($71.6$ Hz) Reley bahosidan 0.3 % ga farq qiladi. 3D modelning (A) varianti $70.4$ Hz beradi ($-1.7 %$). Bu farq 9-maşğulotda ham kuzatilgan keng plita effekti bilan izohlanadi.

== Kontakt modelining taʼsiri

(B) variantda birinçi çastota ikki baravar oşgan. Sababini taxminiy hisob körsatadi. Relslar ($15 times 12.5$ mm, pölat) plita bilan yaxlit işlaganda kesimni alyuminiyga keltiriş uçun ularning yuzasi $n_E = 210 \/ 69 approx 3.04$ marta oşiriladi. Bunda keltirilgan inersiya momenti taxminan $1.92 times 10^5 "mm"^4$ ga, yaʼni plitaning özinikidan qariyb 4.9 marta oşadi. Çastota $sqrt(4.9) approx 2.2$ marta oşib, $approx 158$ Hz böladi. Bu FEM qiymatiga (148 Hz) yaqin; farq relslar massasi qöşilgani bilan boğliq.

Haqiqatda relslar plitaga boltlar bilan mahkamlangan va töliq yaxlit işlamaydi. Demak, haqiqiy çastota (A) va (B) oraliğida yotadi. Uni faqat tajriba (masalan, modal bolğa bilan zarbali sinov) aniqlay oladi. Bu validatsiyaning nima uçun zarurligini körsatadi: kontakt farazi natijani 2 marta özgartirişi mumkin.

== Validatsiya natijalari

6-tajriba stendining FEM modeli rezonans va antirezonans çastotalarini 0.2--0.5 % xatolik bilan beradi (@tab-valid). Bu modelda massalar va bikrlik aniq maʼlum bölgani uçun FEM ham, ikki massali nazariya ham tajribaga juda yaqin natija beradi. Qolgan farq asosan çastota ölçaş aniqligi ($plus.minus 0.1$ Hz) va disklar inersiyasining geometriya böyiça hisoblaş noaniqligi bilan boğliq.

== Boşqaruv uçun xulosa

Modulning birinçi konstruktiv modasi taxminan $70 dots 150$ Hz oraliğida. 6-tajribada körsatilganidek, boşqaruv konturining kesiş çastotasi birinçi mexanik rezonansdan bir neça marta past bölişi kerak. Asos plitasi qattiq ramaga mahkamlansa (9-maşğulot taklifi), plitaning egiliş modasi yöqoladi. Bunda birinçi moda karetkaning relslar ustida ağdarilişi (200 Hz dan yuqori) böladi va servokonturni yuqoriroq ötkazuvçanlik bilan sozlaş mumkin.

= Nazorat savollari

+ FEM da şakl funksiyalari qanday vazifani bajaradi? Nima uçun Eyler--Bernulli tösin elementida kubik funksiyalar qöllaniladi?
+ Bikrlik va massa matritsalari qanday yiğiladi? Çegaraviy şartlar ularga qanday qöllaniladi?
+ 1D, 2D va 3D elementlar qaysi hollarda qöllaniladi? Nima uçun egilişda tet10 elementlari afzal?
+ CAD modelini FEM uçun soddalaştirişda qaysi elementlarni olib taşlaş mumkin, qaysilarini esa saqlaş kerak?
+ Nuqtaviy massa, RBE2 va RBE3 boğlanişlari nima uçun işlatiladi?
+ Birlaşgan (_bonded_) va kirib ketmaslik kontaktlari natijaga qanday taʼsir qiladi?
+ Erkin-erkin modal tahlil modelni tekşirişda qanday yordam beradi?
+ Verifikatsiya va validatsiya qanday farqlanadi? Har biriga misol keltiring.
+ Nima uçun katalog formulasi FEM ga nisbatan 20 % kiçik kritik çastota beradi?
+ Modulning birinçi xususiy çastotasi servoyuritmani sozlaşga qanday taʼsir qiladi?
