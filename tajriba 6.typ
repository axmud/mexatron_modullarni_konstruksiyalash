// ============================================================
//  Mexatron modullarni konstruksiyalash — Vibratsion xususiyatlar — tajriba mashgʻuloti — Typst versiyasi
//  Kompilyatsiya: typst compile tajriba_6.typ
// ============================================================

#import "@preview/cetz:0.4.2"

#let headingblue = rgb(20, 50, 120)

#set document(title: "Mexatron modulning vibratsion xususiyatlarini tadqiq qilish")
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2cm),
)
// ===== HOSHIYA =====
#let info = json("fan.json")
#let raqam = 6  // amaliyot raqami
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

// Chizmalar uchun ranglar
#let pblue = rgb(26, 82, 118)
#let dslate = rgb(44, 62, 80)
#let lbg = rgb(245, 247, 250)

// Ikki massali stendning parametrlari (chizmalar uchun)
#let pJm = 2.0e-4    // dvigatel tomoni inersiya momenti, kg·m²
#let pJL = 6.0e-4    // yuklama diski inersiya momenti, kg·m²
#let pk = 12.0       // muftaning buralish bikrligi, N·m/rad
#let pc = 0.003394   // muftaning soʻndirish koeffitsienti, N·m·s/rad

// ---------------- Sarlavha ----------------
#align(center)[
  #set par(justify: false)
  #text(size: 20pt, weight: "bold", fill: headingblue)[TAJRIBA MASHGʻULOTI №6]
  #v(0.4cm)
  #text(
    size: 14pt,
    weight: "bold",
  )[Mavzu: Mexatron modulning vibratsion xususiyatlarini tadqiq qilish]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Ishning maqsadi

*Mashgʻulotning maqsadi:* elastik bogʻlanishli servoyuritma modulining xususiy tebranish chastotalari, soʻnish koeffitsientlari va chastota xarakteristikalarini tajribaviy aniqlash. Erkin soʻnuvchi tebranishlar va chastota boʻyicha qoʻzgʻatish (_chirp_) usullari yordamida modulning rezonans va antirezonans chastotalarini topish, ularni ikki massali model asosidagi nazariy hisob bilan solishtirish. Datchikni dvigatel tomonida (kollokatsiyalangan) va yuklama tomonida (kollokatsiyalanmagan) joylashtirishning chastota xarakteristikasiga taʼsirini tahlil qilish. Natijalar asosida bikrlik va inersiya nisbatini tanlash orqali modulning dinamik xossalarini konstruktiv yaxshilash koʻnikmalarini shakllantirish.

= Laboratoriya jihozlari va stend komponentlari

+ *Ikki massali buralma tebranish stendi:* servodvigatel (rotor va gupchak bilan birga keltirilgan inersiya momenti $J_m approx 2.0 times 10^(-4) "kg" dot "m"^2$), almashtiriladigan elastik muftalar (buralish bikrligi $k_1 approx 12 "N" dot "m/rad"$ va $k_2 approx 24 "N" dot "m/rad"$) hamda yuklama diski ($J_L = 6.0 times 10^(-4) "kg" dot "m"^2$, geometriya boʻyicha hisoblangan).
+ *Qoʻshimcha inersiya diski:* $Delta J = 3.0 times 10^(-4) "kg" dot "m"^2$, yuklama diskiga boltlar bilan mahkamlanadi.
+ *Servodrayver:* moment (tok) rejimida ishlaydi, ichki signal generatoriga ega (sinusoidal, _chirp_ va PRBS qoʻzgʻatish signallari), tok konturining oʻtkazish polosasi $> 1 "kHz"$.
+ *Inkremental optik enkoderlar:*
  - dvigatel valida: $N_m = 2500$ PPR (kvadratur rezolyutsiya $4 N_m = 10 thin 000$ hisob/ayl);
  - yuklama diskida: $N_L = 5000$ PPR (kvadratur rezolyutsiya $4 N_L = 20 thin 000$ hisob/ayl).
+ *Dvigatel valini qulflash moslamasi:* elektromagnit tormoz (erkin tebranish tajribasida dvigatel tomonini qoʻzgʻalmas qilish uchun).
+ *Maʼlumotlarni yigʻish tizimi (DAQ):* National Instruments USB-6363 / LabVIEW majmuasi (enkoder hisoblagichlari, analog kirishlar, $f_s = 5 "kS/s"$).
+ *Dasturiy muhit:* LabVIEW (maʼlumot yigʻish), Python (NumPy, SciPy --- FFT va chastota xarakteristikasini baholash).

= Mexatron modul tebranishlarining nazariy asoslari

== Mexatron modullarda tebranishlar manbai va ahamiyati

Mexatron modulning mexanik qismi hech qachon mutlaqo qattiq boʻlmaydi: vallar, muftalar, tishli va tasmali uzatmalar hamda korpus detallari chekli bikrlikka ega. Natijada modul bir nechta massa va ularni bogʻlovchi elastik elementlardan iborat koʻp jismli tizim sifatida harakat qiladi. Bunday tizimning xususiy chastotalari yaqinida tashqi qoʻzgʻatish (rotor disbalansi, tishlar ilashish chastotasi, PWM pulsatsiyasi, keskin pozitsiyalash buyruqlari) kuchli rezonans tebranishlarni yuzaga keltiradi. Rezonans pozitsiyalash aniqligini pasaytiradi, shovqin va charchoq yemirilishiga sabab boʻladi. Eng muhimi, u boshqaruv konturining erishish mumkin boʻlgan oʻtkazish polosasini cheklaydi. Shuning uchun modulning vibratsion xususiyatlarini konstruksiyalash bosqichida bilish zarur.

== Bir erkinlik darajali tebranish tizimi

Elastik element bilan bogʻlangan bitta aylanuvchi massaning harakat tenglamasi:

$ J dot.double(theta) + c dot(theta) + k theta = T(t) $ <eq-1dof>

bunda $J$ --- inersiya momenti, $c$ --- soʻndirish koeffitsienti (N·m·s/rad), $k$ --- buralish bikrligi (N·m/rad). Tizimning asosiy dinamik parametrlari:

$ omega_n = sqrt(k / J), quad zeta = c / (2 sqrt(k J)), quad omega_d = omega_n sqrt(1 - zeta^2) $ <eq-wn>

bunda $omega_n$ --- soʻnmaydigan xususiy chastota, $zeta$ --- nisbiy soʻnish koeffitsienti, $omega_d$ --- soʻnuvchi tebranishlar chastotasi. Garmonik qoʻzgʻatishda amplituda--chastota xarakteristikasi ($r = omega \/ omega_n$):

$ abs(G(j omega)) = (1 \/ k) / sqrt((1 - r^2)^2 + (2 zeta r)^2) $ <eq-amp>

Kichik soʻnishda rezonans choʻqqisining dinamik kuchaytirish koeffitsienti $Q approx 1 \/ (2 zeta)$. Soʻnish koeffitsientini yarim quvvat (−3 dB) nuqtalaridagi chastotalar $f_1$, $f_2$ orqali baholash mumkin:

$ zeta approx (f_2 - f_1) / (2 f_n) $ <eq-halfpower>

== Erkin soʻnuvchi tebranishlar va logarifmik dekrement

Boshlangʻich ogʻish berib qoʻyib yuborilgan tizim $theta(t) = A_0 e^(-zeta omega_n t) cos(omega_d t)$ qonuni boʻyicha tebranadi. Ketma-ket amplitudalar nisbatidan logarifmik dekrement aniqlanadi:

$ delta = 1 / m ln(A_0 / A_m) $ <eq-dec>

bunda $A_m$ --- $m$ ta davrdan keyingi amplituda. Nisbiy soʻnish koeffitsienti:

$ zeta = delta / sqrt(4 pi^2 + delta^2) $ <eq-zeta>

Agar inersiya momenti nomaʼlum boʻlsa, bikrlik ikki oʻlchash orqali topiladi: avval asl tizimning chastotasi $omega_1$, keyin maʼlum $Delta J$ qoʻshimcha inersiya bilan chastota $omega_2$ oʻlchanadi. (@eq-wn) dan $k = J omega_1^2 = (J + Delta J) omega_2^2$ boʻlgani uchun:

$ k = (Delta J thin omega_1^2 omega_2^2) / (omega_1^2 - omega_2^2), quad J = k / omega_1^2 $ <eq-addmass>

== Elastik bogʻlanishli ikki massali model

Servodvigatel va yuklama elastik mufta (yoki val, tasma, reduktor) orqali bogʻlangan modulning asosiy almashtiruvchi modeli ikki massali tizimdir (@fig-model):

$ J_m dot.double(theta)_m = T_m - k (theta_m - theta_L) - c (dot(theta)_m - dot(theta)_L) $ <eq-2m1>

$ J_L dot.double(theta)_L = k (theta_m - theta_L) + c (dot(theta)_m - dot(theta)_L) - T_L $ <eq-2m2>

Dvigatel momenti $T_m$ dan dvigatel tezligi $Omega_m$ gacha va yuklama tezligi $Omega_L$ gacha boʻlgan uzatish funksiyalari:

$ G_m (s) = Omega_m / T_m = (J_L s^2 + c s + k) / (s [J_m J_L s^2 + c (J_m + J_L) s + k (J_m + J_L)]) $ <eq-Gm>

$ G_L (s) = Omega_L / T_m = (c s + k) / (s [J_m J_L s^2 + c (J_m + J_L) s + k (J_m + J_L)]) $ <eq-GL>

Maxrajning ildizlari rezonans chastotasini, $G_m$ suratining ildizlari esa antirezonans chastotasini beradi:

$
  omega_"ar" = sqrt(k / J_L), quad omega_r = sqrt((k (J_m + J_L)) / (J_m J_L)) = omega_"ar" sqrt(1 + J_L / J_m)
$ <eq-wr>

Muhim xulosa: rezonans va antirezonans chastotalari nisbati faqat inersiya nisbati $J_L \/ J_m$ ga bogʻliq va bikrlikka bogʻliq emas. Bikrlikni oshirish ikkala chastotani ham $sqrt(k)$ ga proporsional ravishda yuqoriga suradi. Antirezonans chastotasi esa dvigatel tomoni qulflangan holdagi yuklama diskining xususiy chastotasiga teng.

== Datchik joylashuvi: kollokatsiya

Janschekning koʻp jismli tizimlar tahliliga koʻra, harakatni qoʻzgʻatish va oʻlchash bir jismda amalga oshirilsa, konfiguratsiya _kollokatsiyalangan_ deyiladi. Bu holda uzatish funksiyasida har bir rezonans qutblari juftidan oldin antirezonans nollari jufti joylashadi (@eq-Gm). Faza esa $-180 degree$ dan pastga tushmaydi. Yuklama tomonidagi datchik bilan (_kollokatsiyalanmagan_ konfiguratsiya, @eq-GL) antirezonans yoʻqoladi. Rezonansdan keyin amplituda $omega^(-3)$ qonuni boʻyicha tez kamayadi, faza esa yana $-180 degree$ ga siljiydi. Bu boshqaruv konturining turgʻunligini sezilarli darajada qiyinlashtiradi. Lekin parazit kechikishlar (datchik, hisoblash, PWM) tufayli kollokatsiyalangan tizimda ham yuqori chastotali rezonanslar turgʻunlik muammosini yuzaga keltirishi mumkin.

== Konstruktiv xulosalar

Mexatron modulni konstruksiyalashda tebranish xossalarini yaxshilashning asosiy yoʻllari:

+ uzatma elementlarining buralish bikrligi $k$ ni oshirish ($omega_"ar"$ va $omega_r$ yuqoriga suriladi);
+ inersiya nisbatini $J_L \/ J_m$ kamaytirish (rezonans va antirezonans bir-biriga yaqinlashadi, ularning taʼsiri susayadi);
+ elastik elementlarda soʻndirishni oshirish (rezonans choʻqqisi pasayadi);
+ boshqaruv tomonida rezonans chastotasiga sozlangan rejektor (_notch_) filtrdan foydalanish.

Amaliyotda tezlik konturining kesish chastotasi antirezonans chastotasidan bir necha marta (odatda 3--5 marta) past tanlanadi.

#figure(
  cetz.canvas(length: 0.95cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))

    // Zamin
    line((-1.2, -1.6), (11.2, -1.6), stroke: 1pt + dslate)
    for j in range(0, 25) {
      let x = -1.1 + j * 0.5
      line((x, -1.6), (x - 0.3, -1.9), stroke: 0.5pt + dslate)
    }

    // Dvigatel massasi
    rect((0, -1.2), (2.2, 1.2), fill: green.lighten(85%), stroke: 1pt + dslate, radius: 0.08)
    content((1.1, 0.25), text(size: 9pt)[*Servo-* \ *dvigatel*])
    content((1.1, -0.65), text(size: 9pt)[$J_m$])

    // Yuklama massasi
    rect((7.8, -1.2), (10.0, 1.2), fill: red.lighten(85%), stroke: 1pt + dslate, radius: 0.08)
    content((8.9, 0.25), text(size: 9pt)[*Yuklama* \ *diski*])
    content((8.9, -0.65), text(size: 9pt)[$J_L$])

    // Prujina (zigzag)
    let y1 = 0.55
    let zz = ((2.2, y1), (3.2, y1))
    for j in range(0, 8) {
      let x = 3.2 + (j + 0.5) * 0.45
      zz.push((x, y1 + if calc.rem(j, 2) == 0 { 0.3 } else { -0.3 }))
    }
    zz.push((6.8, y1))
    zz.push((7.8, y1))
    line(..zz, stroke: 1pt + pblue)
    content((5.0, y1 + 0.45), text(size: 9pt, fill: pblue)[$k$], anchor: "south")

    // Dempfer
    let y2 = -0.55
    line((2.2, y2), (4.4, y2), stroke: 1pt + dslate)
    line((4.4, y2 - 0.3), (4.4, y2 + 0.3), stroke: 1pt + dslate)
    line((4.0, y2 - 0.35), (5.6, y2 - 0.35), (5.6, y2 + 0.35), (4.0, y2 + 0.35), stroke: 1pt + dslate)
    line((5.6, y2), (7.8, y2), stroke: 1pt + dslate)
    content((5.0, y2 - 0.45), text(size: 9pt)[$c$], anchor: "north")

    // Moment va burchaklar
    line((-1.2, 0), (0, 0), stroke: 1.2pt + red.darken(10%), mark: (end: ">", fill: red.darken(10%)))
    content((-1.2, 0.1), text(size: 9pt, fill: red.darken(20%))[$T_m$], anchor: "south-west")
    line((11.2, 0), (10.0, 0), stroke: 1.2pt + dslate, mark: (end: ">", fill: dslate))
    content((11.2, 0.1), text(size: 9pt)[$T_L$], anchor: "south-east")

    line((0.3, 1.6), (1.9, 1.6), stroke: 1pt + pblue, mark: (end: ">", fill: pblue))
    content((1.1, 1.65), text(size: 9pt, fill: pblue)[$theta_m$ (enkoder 1)], anchor: "south")
    line((8.1, 1.6), (9.7, 1.6), stroke: 1pt + pblue, mark: (end: ">", fill: pblue))
    content((8.9, 1.65), text(size: 9pt, fill: pblue)[$theta_L$ (enkoder 2)], anchor: "south")
  }),
  caption: [Elastik bogʻlanishli servoyuritma modulining ikki massali ekvivalent modeli],
) <fig-model>

= Tajriba stendining sxemasi

Tajriba stendining funksional blok-sxemasi @fig-stend da keltirilgan. Servodrayver moment rejimida ishlaydi va dvigatelga berilgan qoʻzgʻatish momentini ($T_m = k_t I$) hosil qiladi. Ikkala enkoder signallari DAQ hisoblagichlari orqali bir vaqtda yozib olinadi. Keyin kompyuterda burchak tezliklari va chastota xarakteristikalari hisoblanadi.

#figure(
  cetz.canvas(length: 0.95cm, {
    import cetz.draw: *
    let blk(c, w, h, fill, stroke: 1pt + dslate, body) = {
      rect(
        (c.at(0) - w / 2, c.at(1) - h / 2),
        (c.at(0) + w / 2, c.at(1) + h / 2),
        fill: fill,
        stroke: stroke,
        radius: 0.1,
      )
      content(c, align(center, text(size: 7.5pt, body)))
    }
    let sig(from, to, col) = line(
      from,
      to,
      stroke: (paint: col, thickness: 1pt, dash: "dashed"),
      mark: (end: ">", fill: col),
    )

    blk((3.6, 2.4), 5, 1.1, green.lighten(85%))[*Servodrayver* \ (moment rejimi, _chirp_ generatori)]
    line((3.6, 1.85), (3.6, 0.6), stroke: 1.2pt + red.darken(20%), mark: (end: ">", fill: red.darken(20%)))
    content((3.7, 1.25), text(size: 7pt)[$I prop T_m$], anchor: "west")

    // Val chizigʻi
    line((0, 0), (13.2, 0), stroke: 2.5pt + dslate)

    blk((0, 0), 2.2, 1.1, blue.lighten(90%), stroke: 1pt + pblue)[*Enkoder 1* \ $N_m = 2500$ PPR]
    blk((1.6, 0), 0.8, 1.0, gray.lighten(60%))[*T*]
    blk((3.6, 0), 2.2, 1.2, green.lighten(80%))[*Servo-* \ *dvigatel* ($J_m$)]
    blk((6.9, 0), 2.4, 1.0, orange.lighten(80%))[*Elastik mufta* \ ($k_1$ yoki $k_2$)]
    blk((10.2, 0), 2.2, 1.3, red.lighten(85%))[*Yuklama diski* \ ($J_L + Delta J$)]
    blk((13.2, 0), 2.2, 1.1, blue.lighten(90%), stroke: 1pt + pblue)[*Enkoder 2* \ $N_L = 5000$ PPR]
    content((1.6, 0.6), text(size: 6.5pt)[tormoz], anchor: "south")

    blk(
      (6.6, -2.4),
      15.0,
      1.1,
      purple.lighten(88%),
    )[*NI DAQ USB-6363* \ (ikki enkoder hisoblagichi, qoʻzgʻatish signali analog kirishi)]
    blk(
      (6.6, -4.5),
      7.0,
      1.1,
      blue.lighten(85%),
    )[*Shaxsiy kompyuter / LabVIEW, Python* \ (FFT, $H_1$ baholash, logarifmik dekrement)]

    sig((0, -0.55), (0, -1.85), pblue)
    sig((13.2, -0.55), (13.2, -1.85), pblue)
    sig((3.6, -0.6), (3.6, -1.85), green.darken(40%))
    content((3.7, -1.2), text(size: 7pt)[qoʻzgʻatish signali], anchor: "west")
    line((6.6, -2.95), (6.6, -3.95), stroke: 1.2pt + dslate, mark: (end: ">", fill: dslate))
  }),
  caption: [Mexatron modulning vibratsion xususiyatlarini tadqiq qilish stendining blok-sxemasi],
  placement: auto,
) <fig-stend>

= Tajriba mashgʻulotini bajarish tartibi

*Xavfsizlik talablari:* qoʻzgʻatish momenti amplitudasini $0.05 "N" dot "m"$ dan oshirmang. Rezonans chastotasida tebranish amplitudasi keskin ortadi, shuning uchun yuklama diskining burilish amplitudasini kuzatib boring va $5 degree$ dan oshsa, sinovni toʻxtating. Muftani almashtirish va qoʻshimcha diskni oʻrnatishni faqat servodrayver oʻchirilgan holatda bajaring.

== 1-topshiriq: erkin soʻnuvchi tebranishlar orqali antirezonans chastotasi va soʻnishni aniqlash

+ Stendga $k_1$ muftani oʻrnating. Elektromagnit tormoz bilan dvigatel valini qulflang. Bu holda tizim $J_L$ va $k$ dan iborat bir erkinlik darajali tizimga aylanadi.
+ Yuklama diskini qoʻlda $theta_0 approx 20 "mrad"$ ga burib, keskin qoʻyib yuboring. Enkoder 2 signalini 1 s davomida $f_s = 5 "kS/s"$ chastotada yozib oling.
+ Tebranish egri chizigʻidan ketma-ket musbat amplitudalar $A_0, A_1, dots, A_6$ va ularning vaqtlarini aniqlang (@fig-decay). Soʻnuvchi tebranishlar davri $T_d$ ni va chastotasi $f_d = 1 \/ T_d$ ni hisoblang.
+ (@eq-dec) va (@eq-zeta) boʻyicha $delta$ va $zeta$ ni toping.
+ Yuklama diskiga $Delta J$ qoʻshimcha diskni oʻrnatib, tajribani takrorlang. (@eq-addmass) boʻyicha muftaning bikrligi $k$ va yuklama inersiyasi $J_L$ ni aniqlang.

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // x: 1 birlik = 30 ms; y: 1 birlik = 5 mrad
    let wn = calc.sqrt(pk / pJL)
    let zt = pc / (2 * calc.sqrt(pk * pJL))
    let wd = wn * calc.sqrt(1 - zt * zt)
    let A0 = 20.0
    grid(
      (0, -4),
      (10, 4),
      step: 1,
      stroke: 0.3pt + luma(220),
    )
    line((0, 0), (10.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    content((10.6, 0), text(size: 9pt)[$t$ \[ms\]], anchor: "west")
    line((0, -4), (0, 4.5), stroke: 1pt, mark: (end: ">", fill: black))
    content((0, 4.55), text(size: 9pt)[$theta_L$ \[mrad\]], anchor: "south")
    for j in range(0, 11, step: 2) {
      content((j, -4.1), text(size: 7.5pt)[#(j * 30)], anchor: "north")
    }
    for j in range(-4, 5, step: 2) {
      content((-0.1, j), text(size: 7.5pt)[#(j * 5)], anchor: "east")
    }
    let N = 600
    let pts = range(0, N + 1).map(j => {
      let t = 0.3 * j / N
      (t / 0.03, A0 * calc.exp(-zt * wn * t) * calc.cos(wd * t) / 5)
    })
    line(..pts, stroke: 1.2pt + pblue)
    let env1 = range(0, 61).map(j => {
      let t = 0.3 * j / 60
      (t / 0.03, A0 * calc.exp(-zt * wn * t) / 5)
    })
    let env2 = env1.map(p => (p.at(0), -p.at(1)))
    line(..env1, stroke: (paint: red.darken(10%), thickness: 0.8pt, dash: "dashed"))
    line(..env2, stroke: (paint: red.darken(10%), thickness: 0.8pt, dash: "dashed"))
    for i in range(0, 7) {
      let t = i * 2 * calc.pi / wd
      circle((t / 0.03, A0 * calc.exp(-zt * wn * t) / 5), radius: 0.08, fill: red, stroke: none)
      content((t / 0.03, A0 * calc.exp(-zt * wn * t) / 5 + 0.1), text(size: 7pt)[$A_#i$], anchor: "south")
    }
    content(
      (6.3, 3.0),
      text(size: 8pt, fill: red.darken(20%))[$A_0 e^(-zeta omega_n t)$ --- oʻram chiziq],
      anchor: "west",
    )
    // Davr belgisi
    let td = 2 * calc.pi / wd / 0.03
    line((0, -3.3), (td, -3.3), stroke: 0.8pt, mark: (start: ">", end: ">", fill: black, scale: 0.6))
    content((td / 2, -3.3), box(fill: white, inset: 1.5pt, text(size: 8pt)[$T_d$]))
  }),
  caption: [Dvigatel tomoni qulflanganda yuklama diskining erkin soʻnuvchi tebranishlari],
) <fig-decay>

== 2-topshiriq: chastota xarakteristikasini oʻlchash (rezonans va antirezonans)

+ Tormozni oʻchiring (dvigatel vali erkin). Servodrayverni moment rejimiga oʻtkazing.
+ Dvigatelga chastotasi $f = 2 dots 200 "Hz"$ oraligʻida logarifmik oʻsuvchi _chirp_ momentini bering (amplituda $0.03 "N" dot "m"$, davomiyligi 20 s). Kichik oʻzgarmas tezlik ($approx 60$ ayl/min) qoʻshib, quruq ishqalanishning nochiziqli taʼsirini kamaytiring.
+ Qoʻzgʻatish signali $T_m (t)$, dvigatel tezligi $omega_m (t)$ va yuklama tezligi $omega_L (t)$ ni bir vaqtda yozib oling.
+ Python (SciPy) yordamida $H_1$ baholagich boʻyicha chastota xarakteristikalarini hisoblang:
  $ H_1 (f) = (S_(T y) (f)) / (S_(T T) (f)), quad gamma^2 (f) = abs(S_(T y) (f))^2 / (S_(T T) (f) S_(y y) (f)) $
  bunda $S_(T T)$ --- qoʻzgʻatishning avtospektri, $S_(T y)$ --- oʻzaro spektr, $y = omega_m$ yoki $omega_L$, $gamma^2$ --- kogerentlik funksiyasi. Faqat $gamma^2 > 0.9$ boʻlgan chastotalardagi natijalarni ishonchli deb hisoblang.
+ $abs(G_m (j omega))$ va $abs(G_L (j omega))$ ning Bode diagrammalarini quring (@fig-bode). Antirezonans $f_"ar"$ va rezonans $f_r$ chastotalarini hamda rezonans choʻqqisining −3 dB chastotalari $f_1$, $f_2$ ni aniqlang.

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // x = 5 (log10 f - log10 2); y = (dB + 40) / 12.5
    let fx(f) = 5 * (calc.log(f, base: 10) - calc.log(2, base: 10))
    let dy(db) = (db + 40) / 12.5
    let JJ = pJm + pJL
    let mag(w, coll) = {
      let nr = if coll { pk - pJL * w * w } else { pk }
      let ni = pc * w
      let dr = pk * JJ - pJm * pJL * w * w
      let di = pc * JJ * w
      20 * calc.log(calc.sqrt(nr * nr + ni * ni) / (w * calc.sqrt(dr * dr + di * di)), base: 10)
    }
    for f in (2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200) {
      line((fx(f), 0), (fx(f), 8), stroke: 0.3pt + luma(220))
    }
    for db in range(-40, 61, step: 20) {
      line((0, dy(db)), (10, dy(db)), stroke: 0.3pt + luma(220))
      content((-0.1, dy(db)), text(size: 7.5pt)[#db], anchor: "east")
    }
    for f in (2, 5, 10, 20, 50, 100, 200) {
      content((fx(f), -0.1), text(size: 7.5pt)[#f], anchor: "north")
    }
    line((0, 0), (10.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    content((10.6, 0), text(size: 9pt)[$f$ \[Hz\]], anchor: "west")
    line((0, 0), (0, 8.5), stroke: 1pt, mark: (end: ">", fill: black))
    content((0, 8.55), text(size: 9pt)[$abs(G)$ \[dB\] (rad/s / N·m)], anchor: "south")

    let N = 500
    let fs = range(0, N + 1).map(j => 2 * calc.pow(10, 2 * j / N))
    let pm = fs.map(f => (fx(f), dy(calc.max(-40, calc.min(60, mag(2 * calc.pi * f, true))))))
    let pl = fs.map(f => (fx(f), dy(calc.max(-40, calc.min(60, mag(2 * calc.pi * f, false))))))
    line(..pm, stroke: 1.5pt + pblue)
    line(..pl, stroke: 1.5pt + orange.darken(20%))

    let far = calc.sqrt(pk / pJL) / (2 * calc.pi)
    let fr = calc.sqrt(pk * JJ / (pJm * pJL)) / (2 * calc.pi)
    line((fx(far), 0), (fx(far), 8), stroke: (paint: dslate, thickness: 0.8pt, dash: "dashed"))
    line((fx(fr), 0), (fx(fr), 8), stroke: (paint: dslate, thickness: 0.8pt, dash: "dashed"))
    content((fx(far) - 0.05, 7.7), text(size: 8pt)[$f_"ar"$], anchor: "east")
    content((fx(fr) + 0.05, 7.7), text(size: 8pt)[$f_r$], anchor: "west")

    // Afsona
    line((0.4, 1.6), (1.1, 1.6), stroke: 1.5pt + pblue)
    content((1.15, 1.6), text(size: 8pt)[$G_m$ (kollokatsiyalangan)], anchor: "west")
    line((0.4, 1.0), (1.1, 1.0), stroke: 1.5pt + orange.darken(20%))
    content((1.15, 1.0), text(size: 8pt)[$G_L$ (kollokatsiyalanmagan)], anchor: "west")
  }),
  caption: [Ikki massali modulning amplituda--chastota xarakteristikalari: dvigatel va yuklama tezliklari boʻyicha],
) <fig-bode>

== 3-topshiriq: bikrlik va inersiya nisbatining taʼsirini tadqiq qilish

+ 2-topshiriqni quyidagi konfiguratsiyalar uchun takrorlang: (A) $k_1$ mufta, $J_L$; (B) $k_1$ mufta, $J_L + Delta J$; (C) $k_2$ mufta, $J_L$.
+ Har bir konfiguratsiya uchun $f_"ar"$, $f_r$ va $f_r \/ f_"ar"$ nisbatini aniqlang hamda (@eq-wr) boʻyicha hisoblangan qiymatlar bilan solishtiring.
+ Bikrlik oshirilganda chastotalar nisbati oʻzgarmasligini, inersiya nisbati oshirilganda esa ortishini tajribada tekshiring.

= Laboratoriya natijalari va oʻlchash jadvallari

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: 7,
      align: center + horizon,
      stroke: none,
      inset: (x: 7pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header([*Kattalik*], [*$i = 0$*], [*$i = 1$*], [*$i = 2$*], [*$i = 3$*], [*$i = 4$*], [*$i = 5$*]),
      table.hline(stroke: 0.5pt),
      [Vaqt $t_i$ \[ms\]], [0.00], [44.44], [88.88], [133.31], [177.75], [222.19],
      [Amplituda $A_i$ \[mrad\]], [19.94], [17.65], [15.53], [13.73], [12.12], [10.61],
      [$ln(A_0 \/ A_i)$], [0.000], [0.122], [0.250], [0.373], [0.498], [0.631],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Dvigatel tomoni qulflangandagi erkin tebranish amplitudalari ($k_1$ mufta, $J_L$)],
) <tab-decay>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: 4,
      align: (left + horizon, center + horizon, center + horizon, center + horizon),
      stroke: none,
      inset: (x: 7pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header([*Holat*], [*Davr \ $T_d$ \[ms\]*], [*Chastota \ $f_d$ \[Hz\]*], [*Nisbiy soʻnish \ $zeta$*]),
      table.hline(stroke: 0.5pt),
      [Yuklama diski ($J_L$)], [44.44], [22.50], [0.0201],
      [Qoʻshimcha disk bilan ($J_L + Delta J$)], [54.47], [18.36], [0.0164],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Erkin tebranishlar boʻyicha aniqlangan chastota va soʻnish koʻrsatkichlari],
) <tab-free>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: 7,
      align: center + horizon,
      stroke: none,
      inset: (x: 5pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        table.cell(rowspan: 2)[*Konfiguratsiya*],
        table.cell(colspan: 3)[*Nazariy hisob (@eq-wr)*],
        table.cell(colspan: 3)[*Tajriba natijasi*],
        [*$f_"ar"$ \[Hz\]*], [*$f_r$ \[Hz\]*], [*$f_r \/ f_"ar"$*],
        [*$f_"ar"$ \[Hz\]*], [*$f_r$ \[Hz\]*], [*$f_r \/ f_"ar"$*],
      ),
      table.hline(stroke: 0.5pt),
      [(A) $k_1$, $J_L$], [22.51], [45.02], [2.000], [22.4], [45.1], [2.013],
      [(B) $k_1$, $J_L + Delta J$], [18.38], [43.10], [2.345], [18.3], [43.0], [2.350],
      [(C) $k_2$, $J_L$], [31.83], [63.66], [2.000], [31.7], [63.9], [2.016],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Turli konfiguratsiyalarda rezonans va antirezonans chastotalari],
) <tab-config>

(A) konfiguratsiyada rezonans choʻqqisining −3 dB chastotalari: $f_1 = 43.3 "Hz"$, $f_2 = 46.9 "Hz"$.

= Namunaviy hisob-kitoblar va matematik tahlil

== Logarifmik dekrement va nisbiy soʻnish koeffitsienti

@tab-decay maʼlumotlari boʻyicha $m = 5$ davr uchun (@eq-dec) ga koʻra:

$ delta = 1 / 5 ln(19.94 / 10.61) = 1 / 5 ln(1.8794) = 0.6309 / 5 approx 0.1262 $

$ zeta = delta / sqrt(4 pi^2 + delta^2) = 0.1262 / sqrt(39.478 + 0.016) approx 0.0201 $

Soʻnuvchi tebranishlar davri $T_d = 222.19 \/ 5 = 44.44 "ms"$, chastotasi $f_d = 22.50 "Hz"$. Kichik soʻnishda $f_n = f_d \/ sqrt(1 - zeta^2) approx 22.51 "Hz"$, yaʼni $f_n approx f_d$. Dinamik kuchaytirish koeffitsienti $Q approx 1 \/ (2 zeta) approx 24.9$.

== Muftaning bikrligi va yuklama inersiyasini aniqlash

@tab-free boʻyicha $omega_1 = 2 pi dot 22.50 approx 141.37 "rad/s"$ ($omega_1^2 approx 19 thin 986 "s"^(-2)$), $omega_2 = 2 pi dot 18.36 approx 115.36 "rad/s"$ ($omega_2^2 approx 13 thin 308 "s"^(-2)$). (@eq-addmass) ga koʻra:

$
  k = (Delta J thin omega_1^2 omega_2^2) / (omega_1^2 - omega_2^2) = (3.0 times 10^(-4) dot 19 thin 986 dot 13 thin 308) / (19 thin 986 - 13 thin 308) \
  approx 11.95 "N" dot "m/rad"
$

$ J_L = k / omega_1^2 = 11.95 / (19 thin 986) approx 5.98 times 10^(-4) "kg" dot "m"^2 $

Olingan $J_L$ qiymati geometriya boʻyicha hisoblangan $6.0 times 10^(-4) "kg" dot "m"^2$ dan 0.4 % ga farq qiladi.

== Rezonans chastotasi va dvigatel inersiyasini baholash

(@eq-wr) boʻyicha nazariy rezonans chastotasi ($J_m = 2.0 times 10^(-4) "kg" dot "m"^2$):

$
  f_r = 1 / (2 pi) sqrt((k (J_m + J_L)) / (J_m J_L)) = 1 / (2 pi) sqrt((12 dot 8.0 times 10^(-4)) / (2.0 times 10^(-4) dot 6.0 times 10^(-4))) \
  = 282.8 / (2 pi) approx 45.02 "Hz"
$

Tajribada $f_r = 45.1 "Hz"$ olingan (farq 0.2 %). Oʻlchangan chastotalar nisbatidan dvigatel tomonining inersiya momentini teskari hisoblash mumkin:

$
  J_m = J_L / ((f_r \/ f_"ar")^2 - 1) = (5.98 times 10^(-4)) / ((45.1 \/ 22.4)^2 - 1) = (5.98 times 10^(-4)) / 3.054 \
  approx 1.96 times 10^(-4) "kg" dot "m"^2
$

Bu usul dvigatel rotori, gupchak va mufta yarmining keltirilgan inersiyasini demontaj qilmasdan aniqlash imkonini beradi.

== Rezonansdagi soʻnishni yarim quvvat usulida baholash

(@eq-halfpower) ga koʻra:

$ zeta_r approx (f_2 - f_1) / (2 f_r) = (46.9 - 43.3) / (2 dot 45.1) approx 0.040 $

Ikki massali modelda nisbiy harakat uchun ekvivalent inersiya $J_"eq" = J_m J_L \/ (J_m + J_L) = 1.5 times 10^(-4) "kg" dot "m"^2$. Shuning uchun bir xil $c$ da $zeta_r = zeta_"ar" sqrt(J_L \/ J_"eq") = 0.020 dot 2 = 0.040$, bu tajriba natijasiga mos keladi.

== Konstruktiv baholash

Nominal moment $T = 0.5 "N" dot "m"$ da muftaning statik buralish burchagi:

$ Delta theta = T / k = 0.5 / 12 approx 0.0417 "rad" approx 2.39 degree $

$k_2 = 24 "N" dot "m/rad"$ muftada bu qiymat $1.19 degree$ gacha kamayadi. Kesish chastotasini antirezonans chastotasidan 3--5 marta past tanlash tavsiyasiga koʻra, (A) konfiguratsiyada tezlik konturining kesish chastotasi taxminan $f_c approx 4.5 dots 7.5 "Hz"$ bilan cheklanadi. (C) konfiguratsiyada esa u $f_c approx 6.4 dots 10.6 "Hz"$ gacha oshadi (@tab-config). Demak, bikrlikni ikki baravar oshirish erishiladigan oʻtkazish polosasini $sqrt(2) approx 1.41$ marta kengaytiradi. Rezonans va antirezonansni bir-biriga yaqinlashtirish uchun esa inersiya nisbatini $J_L \/ J_m$ kamaytirish (masalan, reduktor orqali moslashtirish) kerak.

= Metrologik tahlil va oʻlchash noaniqligi

ISO GUM standartiga muvofiq muftaning bikrligini $k = J_L (2 pi f_"ar")^2$ toʻgʻridan-toʻgʻri usulda aniqlash noaniqligi baholanadi. Bunda $J_L = 6.0 times 10^(-4) "kg" dot "m"^2$ geometriya boʻyicha hisoblangan, $f_"ar" = 22.50 "Hz"$:

$ k = 6.0 times 10^(-4) dot (2 pi dot 22.50)^2 approx 11.99 "N" dot "m/rad" $

+ *Inersiya momenti (B tur).* Disk oʻlchamlari va zichligi boʻyicha chegaraviy xatolik $plus.minus 1 %$. Tekis taqsimotda nisbiy standart noaniqlik $u_J \/ J = 1 % \/ sqrt(3) approx 0.58 %$.
+ *Chastota (A tur).* $n = 5$ ta takroriy oʻlchashda oʻrtacha qiymatning standart ogʻishi $S_(overline(f)) = 0.03 "Hz"$, nisbiy $u_f \/ f = 0.03 \/ 22.50 approx 0.133 %$. DAQ taktli generatorining xatoligi bunga nisbatan juda kichik.
+ *Jamlangan va kengaytirilgan noaniqlik.* $k$ chastotaning kvadratiga proporsional boʻlgani uchun uning nisbiy noaniqligi ikki marta kuchayadi:
  $ u_k / k = sqrt((u_J / J)^2 + (2 u_f / f)^2) = sqrt(0.58^2 + (2 dot 0.133)^2) approx 0.64 % $
  $ u_k = 11.99 dot 0.0064 approx 0.077 "N" dot "m/rad", quad U_k = 2 u_k approx plus.minus 0.15 "N" dot "m/rad" $
  Natija: $k = (11.99 plus.minus 0.15) "N" dot "m/rad"$, $P approx 95 %$. Qoʻshimcha inersiya usulida olingan $11.95 "N" dot "m/rad"$ qiymat shu oraliqqa tushadi. Asosiy noaniqlik manbai inersiya momentidir.

= Nazorat savollari

+ Mexatron modullarda tebranishlarning asosiy qoʻzgʻatuvchi manbalari nimalardan iborat?
+ Soʻnmaydigan xususiy chastota $omega_n$ va soʻnuvchi tebranishlar chastotasi $omega_d$ qanday farqlanadi?
+ Logarifmik dekrement nima va u nisbiy soʻnish koeffitsienti bilan qanday bogʻlangan?
+ Nima uchun qoʻshimcha maʼlum inersiya qoʻshish orqali bikrlik va inersiyani alohida-alohida aniqlash mumkin?
+ Ikki massali tizimda rezonans va antirezonans chastotalari qanday fizik maʼnoga ega?
+ Nima uchun $f_r \/ f_"ar"$ nisbati muftaning bikrligiga bogʻliq emas?
+ Kollokatsiyalangan va kollokatsiyalanmagan datchik joylashuvining chastota xarakteristikasi va boshqaruv turgʻunligiga taʼsirini tushuntiring.
+ $H_1$ baholagich va kogerentlik funksiyasi nima uchun qoʻllaniladi?
+ Mexatron modulni konstruksiyalashda rezonans chastotasini oshirishning qanday konstruktiv usullari mavjud?
+ Rejektor (_notch_) filtr qanday ishlaydi va uni qoʻllashda qanday xavflar mavjud?
