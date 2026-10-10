// ============================================================
//  Mexatron modullarni konstruksiyalash — Tishli uzatma aniqligi — tajriba mashgʻuloti — Typst versiyasi
//  Kompilyatsiya: typst compile mmk_tajriba_tishli_uzatma.typ
// ============================================================

#import "@preview/cetz:0.4.2"

#let headingblue = rgb(20, 50, 120)

#set document(title: "Tishli uzatmaning uzatish aniqligini tadqiq qilish")
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

// Chizmalar uchun ranglar
#let pblue = rgb(26, 82, 118)
#let dslate = rgb(44, 62, 80)
#let lbg = rgb(245, 247, 250)

// ---------------- Sarlavha ----------------
#align(center)[
  #set par(justify: false)
  #text(size: 20pt, weight: "bold", fill: headingblue)[TAJRIBA MASHGʻULOTI №4]
  #v(0.4cm)
  #text(
    size: 14pt,
    weight: "bold",
  )[Mavzu: Tishli uzatmaning uzatish aniqligini tadqiq qilish]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Ishning maqsadi

*Mashgʻulotning maqsadi:* mexatronik modullarda, servoyuritmalarda va aniq pozitsiyalash mexanizmlarida qoʻllaniladigan tishli uzatmalarning kinematik aniqligi, yonboʻshliq (lyuft $j_n$), profil va qadam xatoliklari hamda yuklama ostidagi egiluvchanlik hisobiga yuzaga keluvchi umumiy burchak xatoligini tajribaviy tadqiq qilish. Yuqori ajratish qobiliyatiga ega optik enkoderlar va raqamli maʼlumotlarni yigʻish (DAQ) tizimi yordamida tishli uzatmaning kinematik xatolik egri chizigʻi hamda gisterezis halqasini qurish va metrologik baholash koʻnikmalarini shakllantirish.

= Laboratoriya jihozlari va stend komponentlari

+ *Tadqiqot tishli uzatmasi stendi:* aniq tayyorlangan silindrik toʻgʻri tishli uzatma (modul $m = 1.5 "mm"$, tishlar soni $z_1 = 20$, $z_2 = 60$, uzatish nisbati $i = 3.0$).
+ *Kirish va chiqish enkoderlari:*
  - kirish valida: optik inkremental enkoder ($N_1 = 10 thin 000$ PPR, kvadratur rezolyutsiya $Delta theta_1 = 360 degree \/ (4 N_1) = 0.009 degree$);
  - chiqish valida: yuqori aniqlikdagi optik enkoder ($N_2 = 360 thin 000$ PPR, kvadratur rezolyutsiya $Delta theta_2 = 360 degree \/ (4 N_2) = 0.00025 degree = 0.9''$, pasport aniqligi $plus.minus 3.6''$).
+ *Yuritma va yuklama tizimi:* sinxron servodvigatel (BLDC/PMSM) va boshqariladigan elektromagnit/kukunli tormoz ($0 dots 20 "N" dot "m"$ yuklama momentini hosil qilish uchun).
+ *Burovchi moment datchigi (_torque transducer_):* kontaktsiz tenzometrik moment datchigi (aniqlik sinfi 0.1 %).
+ *Maʼlumotlarni yigʻish tizimi (DAQ):* National Instruments USB-6363 / LabVIEW apparat-dasturiy majmuasi (diskretlash chastotasi $f_s = 100 "kS/s"$).
+ *Mikrometrik soat tipidagi indikator:* oʻqlararo masofani ($a$) va radial urishni oʻlchash uchun (ajratish qobiliyati 0.001 mm).

= Mexatronik tizimlarda tishli uzatmalarning aniqligi va nazariy asoslari

== Tishli uzatmaning kinematik xatoligi

Mexatronik modullarda tishli uzatmalar nafaqat quvvat uzatish, balki harakatni va burchak pozitsiyasini oʻta yuqori aniqlikda shakllantirish vazifasini bajaradi. Ideal tishli uzatmada kirish vali $phi_"in"$ burchakka burilganda chiqish vali nazariy jihatdan quyidagi burchakka burilishi lozim:

$ phi_"out,th" = phi_"in" / i $

bunda $i = z_2 \/ z_1$ --- uzatish nisbati. Amalda esa tish tayyorlashdagi texnologik chetlanishlar (qadam xatoligi $f_"pt"$, profil xatoligi $f_(f alpha)$, radial urish $F_"rr"$) hamda yigʻish xatoliklari (oʻqlarning parallel emasligi, oʻqlararo masofa chetlanishi $Delta a$) sababli haqiqiy burchak $phi_"out,act"$ nazariy qiymatdan farq qiladi. Burchakli kinematik xatolik $Delta phi.alt(phi_"in")$ quyidagicha aniqlanadi (rad yoki arcmin):

$ Delta phi.alt(phi_"in") = phi_"out,act" (phi_"in") - phi_"in" / i $ <eq-kin>

bunda $1 "arcmin" = (1 / 60)degree = pi / 10800 approx 2.9089 times 10^(-4) "rad"$.

== Yonboʻshliq (lyuft) va oʻqlararo masofa taʼsiri

Tishli ilashmada tishlarning yon sirtlari orasida texnologik va termik kengayish kafolati sifatida yonboʻshliq $j_n$ (_backlash_) mavjud boʻlishi shart. Biroq servotizimlarda reversiv (qarama-qarshi yoʻnalishli) harakatda yonboʻshliq «oʻlik zona» (_dead zone_) va pozitsiyalash xatoligini yuzaga keltiradi. Chiqish valiga keltirilgan burchakli lyuft $Delta theta_j$ quyidagi formula bilan ifodalanadi (gradusda):

$ Delta theta_j = (2 j_n) / d_(w 2) dot (180 degree) / pi $ <eq-lyuft>

bunda $j_n$ --- tish sirtlari orasidagi normal yonboʻshliq (mm), $d_(w 2)$ --- chiqish gʻildiragining boʻluvchi diametri ($d_(w 2) = m z_2$).

Oʻqlararo masofaning nominal qiymatdan $Delta a$ miqdorga ortishi normal yonboʻshliqni quyidagi bogʻliqlik boʻyicha oshiradi:

$ Delta j_n = 2 Delta a sin alpha_w $ <eq-da>

bunda $alpha_w = 20 degree$ --- ilashish burchagi. Masalan, $Delta a = 0.05 "mm"$ boʻlganda yonboʻshliq $Delta j_n = 2 dot 0.05 dot sin 20 degree approx 0.0342 "mm"$ ga ortadi.

== Tishli uzatmaning dinamik xatoligi va ilashish tebranishlari

Tishlar ilashishga kirganda va ilashishdan chiqqanda ilashish bikrligi $c(t)$ davriy ravishda oʻzgaradi (bir juft va ikki juft tish ilashish zonalarining almashinuvi). Tishlarning garmonik xatoligi va bikrlik variatsiyasi tebranishlarni vujudga keltiradi. Ilashish chastotasi $f_m$ quyidagicha aniqlanadi (Hz):

$ f_m = (n_1 z_1) / 60 = (n_2 z_2) / 60 $

bunda $n_1$ --- kirish valining aylanish chastotasi (ayl/min). Aylanish tezligi ortishi bilan kinematik xatolik va deformatsiyalar dinamik kuchlarni yuzaga keltiradi. Tishli uzatmaning chiqish valiga keltirilgan umumiy elastik-kinematik xatoligi:

$
  theta_"err" (t) = Delta phi.alt_"kin" (phi) + T_"out" / k_theta + op("sgn")(dot(phi)) dot (Delta theta_j) / 2
$ <eq-err>

bunda $T_"out"$ --- chiqish validagi yuklama momenti, $k_theta$ --- tishli uzatma va vallarning buralish bikrligi (N·m/rad).

= Tajriba stendining sxemasi va ilashish geometriyasi

Tajriba mashgʻulotini oʻtkazish uchun moʻljallangan yuqori aniqlikdagi optik-elektron oʻlchash stendining funksional blok-sxemasi @fig-stend da, tishlar ilashishidagi geometrik parametrlar esa @fig-mesh da keltirilgan.

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

    // Val chiziqlari
    line((0, 0), (13.6, 0), stroke: 2.5pt + dslate)

    blk((0, 0), 2.2, 1.2, green.lighten(85%))[*Servodvigatel* \ (BLDC yuritma)]
    blk((3.4, 0), 2.2, 1.1, blue.lighten(90%), stroke: 1pt + pblue)[*Kirish enkoderi* \ $N_1 = 10 thin 000$ PPR]
    blk((6.8, 0), 2.3, 1.2, orange.lighten(80%))[*Tadqiqot tishli* \ *uzatmasi* ($z_1 \/ z_2$)]
    blk((10.2, 0), 2.3, 1.1, blue.lighten(90%), stroke: 1pt + pblue)[*Chiqish enkoderi* \ $N_2 = 360 thin 000$ PPR]
    blk((13.6, 0), 2.2, 1.2, red.lighten(85%))[*Elektromagnit* \ *tormoz* (yuklama)]

    content((1.7, 0.15), text(size: 7.5pt)[$n_1, T_"in"$], anchor: "south")
    content((11.9, 0.15), text(size: 7.5pt)[$n_2, T_"out"$], anchor: "south")

    blk((6.8, -2.4), 13.8, 1.1, purple.lighten(88%))[*NI DAQ USB-6363* \ (hisoblagichlar va analog kirish moduli)]
    blk((6.8, -4.5), 6.4, 1.1, blue.lighten(85%))[*Shaxsiy kompyuter / LabVIEW* \ (kinematik xatolik va lyuft tahlili)]

    sig((0, -0.6), (0, -1.85), green.darken(40%))
    sig((3.4, -0.55), (3.4, -1.85), pblue)
    sig((10.2, -0.55), (10.2, -1.85), pblue)
    sig((13.6, -0.6), (13.6, -1.85), red.darken(10%))
    line((6.8, -2.95), (6.8, -3.95), stroke: 1.2pt + dslate, mark: (end: ">", fill: dslate))
  }),
  caption: [Tishli uzatmaning kinematik aniqligi va lyuftini oʻlchash tajriba stendining blok-sxemasi],
) <fig-stend>

#figure(
  cetz.canvas(length: 0.95cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))

    // 1-gʻildirak
    circle((0, 0), radius: 1.8, stroke: 1.2pt + pblue)
    circle((0, 0), radius: 1.69, stroke: (paint: gray, dash: "dashed"))
    circle((0, 0), radius: 1.95, stroke: (paint: dslate, dash: "dotted"))
    // 2-gʻildirak
    circle((4.5, 0), radius: 2.7, stroke: 1.2pt + pblue)
    circle((4.5, 0), radius: 2.54, stroke: (paint: gray, dash: "dashed"))
    circle((4.5, 0), radius: 2.85, stroke: (paint: dslate, dash: "dotted"))

    line((-0.5, 0), (7.4, 0), stroke: (thickness: 0.5pt, dash: "dash-dotted"))
    circle((0, 0), radius: 0.06, fill: black)
    content((0, -0.1), [$O_1$], anchor: "north")
    circle((4.5, 0), radius: 0.06, fill: black)
    content((4.5, -0.1), [$O_2$], anchor: "north")
    circle((1.8, 0), radius: 0.08, fill: red)
    content((1.85, 0.05), [$P$], anchor: "south-west")

    line((0, -0.9), (4.5, -0.9), stroke: 1pt, mark: (start: ">", end: ">", fill: black))
    content((2.25, -0.9), box(fill: white, inset: 2pt, text(size: 9pt)[$a = r_(w 1) + r_(w 2)$]))

    // Kattalashtirish zonasi
    rect((1.5, -0.4), (2.1, 0.4), stroke: 1.2pt + red)
    line((2.1, 0.4), (7.75, 2.0), stroke: 1pt + red, mark: (end: ">", fill: red))

    // Kattalashtirilgan detal
    group({
      translate((8.8, 1.2))
      scale(1.3)
      rect((-0.8, -0.8), (1.8, 1.2), fill: luma(240), stroke: 0.6pt + gray)
      bezier((0, -0.6), (0.5, 0.8), (0.2, 0.1), stroke: 1.5pt + pblue)
      bezier((0.9, -0.6), (0.4, 0.8), (0.7, 0.1), stroke: 1.5pt + dslate)
      line((0.31, 0.25), (0.64, 0.25), stroke: 1pt + red, mark: (start: ">", end: ">", fill: red, scale: 0.6))
      content((0.48, 0.3), text(size: 7pt)[$j_n$], anchor: "south")
      content((0.5, -0.7), text(size: 6.5pt)[Normal yonboʻshliq])
    })
    content((10.1, 2.9), text(size: 8.5pt)[*Ilashish va lyuft ($j_n$) zonasi*], anchor: "south")
  }),
  caption: [Tishli uzatma boʻluvchi aylanalarining ilashishi va normal yonboʻshliq ($j_n$) aks etgan geometrik model],
) <fig-mesh>

= Tajriba mashgʻulotini bajarish tartibi

== 1-topshiriq: tishli uzatmaning statik yonboʻshligʻini (lyuftini) aniqlash

+ Tajriba stendining kirish valini statik holatda qulflang (servodvigatel tormoz rejimida).
+ Chiqish valiga burchakli mikrometrik indikator yoki yuqori aniqlikdagi enkoder ($N_2 = 360 thin 000$ PPR) koʻrsatkichini ulagan holda, chiqish valini soat mili yoʻnalishida va unga qarshi minimal $T = plus.minus 0.5 "N" dot "m"$ moment bilan burang.
+ Tishlar kontaktga kirgandagi burchaklar farqini $Delta theta_j$ burchak daqiqasi (arcmin) va mikrometrlarda qayd eting.
+ Oʻlchashni valning $0 degree$, $90 degree$, $180 degree$, $270 degree$ burilish burchaklarida takrorlang va lyuftning radial urishga bogʻliqligini tahlil qiling.

== 2-topshiriq: toʻliq aylanishdagi kinematik xatolikni oʻlchash

+ Servodvigatelni oʻzgarmas past aylanish chastotasida ($n_1 = 60$ ayl/min) harakatlantiring.
+ NI DAQ va LabVIEW dasturi orqali kirish va chiqish enkoderlarining impulslarini bir vaqtning oʻzida yozib oling.
+ Har bir $t_k$ vaqt momentida haqiqiy burchaklar $phi_1(t_k)$ va $phi_2(t_k)$ ni hisoblang:
  $ phi_1(t_k) = (2 pi K_1(t_k)) / (4 N_1), quad phi_2(t_k) = (2 pi K_2(t_k)) / (4 N_2) $
  bunda $K_1, K_2$ --- mos ravishda enkoderlarning kvadratur hisoblari soni.
+ Kinematik xatolik tenglamasi $Delta phi.alt(t_k) = phi_2(t_k) - phi_1(t_k) \/ i$ boʻyicha chiqish gʻildiragining bir toʻliq aylanishi ($phi_2 = 0 dots 360 degree$) uchun kinematik xatolik grafigini quring.

== 3-topshiriq: yuklama ostida gisterezis va buralish bikrligini aniqlash

+ Kirish valini mahkamlang va chiqish valiga bosqichma-bosqich $T_"out" = 0 -> +10 -> 0 -> -10 -> 0 "N" dot "m"$ yuklama momentini bering.
+ Har bir moment qiymatida chiqish valining burilish burchagini qayd qilib, elastik deformatsiya va lyuft birgalikda aks etgan $T$--$theta$ gisterezis halqasini quring (@fig-hyst).

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    grid(
      (-4, -3),
      (4, 3),
      step: 1,
      stroke: 0.3pt + luma(220),
    )
    line((-4, 0), (4.2, 0), stroke: 1pt, mark: (end: ">", fill: black))
    content((4.25, 0), text(size: 9pt)[$T_"out"$ \[N·m\]], anchor: "west")
    line((0, -3), (0, 3.3), stroke: 1pt, mark: (end: ">", fill: black))
    content((0, 3.35), text(size: 9pt)[$theta_"out"$ \[arcmin\]], anchor: "south")

    line(
      (0, 0.8),
      (2.5, 2.3),
      (3.0, 2.6),
      (3.0, 2.4),
      (0.5, 0.9),
      (0, -0.8),
      (-2.5, -2.3),
      (-3.0, -2.6),
      (-3.0, -2.4),
      (-0.5, -0.9),
      (0, 0.8),
      stroke: 1.5pt + pblue,
    )

    line((-0.35, -0.8), (-0.35, 0.8), stroke: 1pt + red, mark: (start: ">", end: ">", fill: red))
    content(
      (-0.4, 0.05),
      box(fill: white, inset: 1.5pt, text(size: 9pt, fill: red.darken(20%))[$Delta theta_j$]),
      anchor: "east",
    )

    line((0.5, 0.9), (3.5, 2.7), stroke: (paint: dslate, thickness: 1pt, dash: "dotted"))
    content((3.5, 2.75), text(size: 9pt)[Bikrlik $k_theta = (Delta T) / (Delta theta)$], anchor: "south")
  }),
  caption: [Tishli uzatmaning yuklama ostidagi burchakli gisterezis va lyuft ($Delta theta_j$) xarakteristikasi],
) <fig-hyst>

= Laboratoriya natijalari va oʻlchash jadvallari

Chiziqli yonboʻshliq $j_n$ (@eq-lyuft) formuladan $j_n = Delta theta_j dot d_(w 2) \/ 2$ ($d_(w 2) = 90 "mm"$) boʻyicha hisoblangan.

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: 6,
      align: center + horizon,
      stroke: none,
      inset: (x: 5pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*Oʻlchash \ №*],
        [*Kirish vali \ $phi_1$ \[°\]*],
        [*Soat mili boʻyicha \ $theta_"cw"$ \[arcmin\]*],
        [*Teskari yoʻnalish \ $theta_"ccw"$ \[arcmin\]*],
        [*Lyuft \ $Delta theta_j$ \[arcmin\]*],
        [*Chiziqli \ $j_n$ \[μm\]*],
      ),
      table.hline(stroke: 0.5pt),
      [1], [0], [+1.20], [−1.15], [2.35], [30.8],
      [2], [90], [+1.45], [−1.30], [2.75], [36.0],
      [3], [180], [+1.80], [−1.65], [3.45], [45.2],
      [4], [270], [+1.30], [−1.20], [2.50], [32.7],
      [5], [360], [+1.22], [−1.16], [2.38], [31.2],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Turli burchak pozitsiyalarida oʻlchangan statik lyuft koʻrsatkichlari],
) <tab-lyuft>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (auto, auto, auto, auto, 1fr),
      align: (center + horizon, center + horizon, center + horizon, center + horizon, left + horizon),
      stroke: none,
      inset: (x: 5pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*Nuqta \ $phi_2$ \[°\]*],
        [*Nazariy \ $phi_"2,th"$ \[°\]*],
        [*Haqiqiy \ $phi_"2,act"$ \[°\]*],
        [*Xatolik \ $Delta phi.alt$ \[arcmin\]*],
        [*Asosiy manba*],
      ),
      table.hline(stroke: 0.5pt),
      [0], [0.0000], [0.0000], [0.00], [Baza nuqtasi],
      [60], [60.0000], [60.0210], [+1.26], [Tish qadami xatoligi],
      [120], [120.0000], [120.0540], [+3.24], [Radial urish],
      [180], [180.0000], [180.0820], [+4.92], [Maksimal urish],
      [240], [240.0000], [240.0410], [+2.46], [Profil xatoligi],
      [300], [300.0000], [300.0120], [+0.72], [Qadam kompensatsiyasi],
      [360], [360.0000], [360.0005], [+0.03], [Davr yakuni],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Tishli uzatmaning davriy kinematik xatoligi va uning asosiy manbalari],
) <tab-kin>

= Namunaviy hisob-kitoblar va matematik tahlil

== Burchakli lyuftdan chiziqli yonboʻshliqni hisoblash

Oʻlchangan burchakli lyuft $Delta theta_j = 3.45 "arcmin"$, chiqish gʻildiragining boʻluvchi diametri $d_(w 2) = m z_2 = 1.5 dot 60 = 90 "mm"$ boʻlganda:

$ Delta theta_j = 3.45 dot pi / 10800 approx 1.0036 times 10^(-3) "rad" $

$ j_n = (Delta theta_j dot d_(w 2)) / 2 = (1.0036 times 10^(-3) dot 90) / 2 approx 0.04516 "mm" = 45.16 thin mu"m" $

== Oʻqlararo masofa chetlanishidan kelib chiqadigan lyuft

Nominal oʻqlararo masofa $a = m (z_1 + z_2) \/ 2 = 1.5 (20 + 60) \/ 2 = 60 "mm"$ oʻrniga $a_"act" = 60.04 "mm"$ ($Delta a = +0.04 "mm"$) boʻlsa, (@eq-da) formulaga koʻra:

$ Delta j_n = 2 Delta a sin 20 degree = 2 dot 0.04 dot 0.3420 approx 0.02736 "mm" = 27.36 thin mu"m" $

== Tishli uzatmaning buralish bikrligini ($k_theta$) aniqlash

$T_1 = 2.0 "N" dot "m"$ da $theta_1 = 1.2 "arcmin"$, $T_2 = 10.0 "N" dot "m"$ da $theta_2 = 4.8 "arcmin"$ boʻlganda:

$ Delta T = 10.0 - 2.0 = 8.0 "N" dot "m" $

$ Delta theta = (4.8 - 1.2) "arcmin" = 3.6 dot 2.9089 times 10^(-4) approx 1.0472 times 10^(-3) "rad" $

$ k_theta = (Delta T) / (Delta theta) = 8.0 / (1.0472 times 10^(-3)) approx 7639 "N" dot "m/rad" $

= Metrologik tahlil va oʻlchash noaniqligi

ISO GUM (_Guide to the Expression of Uncertainty in Measurement_) xalqaro standartiga muvofiq kinematik xatolikni oʻlchashdagi A va B turdagi noaniqliklar baholanadi.

+ *A turdagi noaniqlik (takroriy oʻlchashlar boʻyicha).* $n = 5$ marta takrorlangan oʻlchashlarda oʻrtacha qiymatning standart ogʻishi:
  $ S_(overline(x)) = sqrt((sum_(i=1)^n (x_i - overline(x))^2) / (n (n - 1))) = 0.12 "arcmin" $
+ *B turdagi noaniqlik (enkoder va DAQ xatoligi).* Chiqish enkoderining pasport xatoligi $delta_"enc" = 3.6'' = 0.06 "arcmin"$. Tekis (toʻgʻri burchakli) taqsimotda:
  $ u_B = 0.06 / sqrt(3) approx 0.0346 "arcmin" $
+ *Kengaytirilgan noaniqlik ($U$).* Jamlangan standart noaniqlik:
  $ u_c = sqrt(S_(overline(x))^2 + u_B^2) = sqrt(0.12^2 + 0.0346^2) approx 0.125 "arcmin" $
  Qamrov koeffitsienti $k = 2$ ($P approx 95 %$) boʻlganda kengaytirilgan noaniqlik:
  $ U = k dot u_c = 2 dot 0.125 = plus.minus 0.25 "arcmin" $

= Nazorat savollari

+ Mexatronik modullarda tishli uzatmalarning kinematik xatoligiga qanday asosiy omillar taʼsir koʻrsatadi?
+ Burchakli lyuft (_backlash_) va yonboʻshliq $j_n$ oʻrtasidagi matematik bogʻliqlikni tushuntiring.
+ Oʻqlararo masofaning ortishi ($Delta a$) ilashish burchagi va lyuftga qanday taʼsir qiladi?
+ Tishli uzatmalarda gisterezis halqasi nimani anglatadi va u pozitsiyalash aniqligiga qanday taʼsir koʻrsatadi?
+ Optik enkoderlar yordamida kinematik xatolikni oʻlchashda enkoder rezolyutsiyasiga qanday talablar qoʻyiladi?
+ Servoyuritmalarda dasturiy lyuft kompensatsiyasi (_software backlash compensation_) algoritmi qanday ishlaydi?
+ Toʻlqinli (_harmonic drive_) va planetar tishli reduktorlarning kinematik aniqligi oddiy silindrik uzatmalardan nimasi bilan farq qiladi?
+ ISO GUM standarti boʻyicha A va B turdagi noaniqliklar qanday jamlanadi?
+ Tishlarning ilashish chastotasi ($f_m$) va tebranish spektri oʻrtasidagi bogʻliqlikni tushuntiring.
+ Yuqori aniqlikdagi tishli uzatmalarda tish profilini modifikatsiyalash (_crowning_ / _tip relief_) aniqlik va shovqin darajasini qanday yaxshilaydi?
