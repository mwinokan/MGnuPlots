###### TERMINAL OPTIONS ######

set term pngcairo enhanced solid font 'Arial,24' size 900,675  # 0.5 textwidth on letter paper

###### LINETYPES ######

temp_lw = 2

# set linetype 99 lc 1 dashtype solid

set linetype 9  lc 8 lw temp_lw pt 7  ps 1 # black circle
set linetype 10 lc 7 lw temp_lw pt 5  ps 1 # red square
set linetype 11 lc 6 lw temp_lw pt 9  ps 1 # blue triangle
set linetype 12 lc 2 lw temp_lw pt 13 ps 1 # green diamond
set linetype 13 lc 4 lw temp_lw pt 11 ps 1 # orange triangle (mirror)
set linetype 14 lc 1 lw temp_lw pt 7 ps 1  # purple circles, etc
set linetype 15 lc 3 lw temp_lw pt 15 ps 1  # cyan pentagons, etc
set linetype 16 lc 5 lw temp_lw pt 6 ps 1  # yellow ring, etc
set linetype 17 lc rgb 'red' lw temp_lw pt 4 ps 1  # red bright square nofill, etc
set linetype 18 lc rgb 'blue' lw temp_lw pt 8 ps 1  # blue bright triangle nofill, etc
set linetype 19 lc rgb 'green' lw temp_lw pt 12 ps 1  # green bright square nofill, etc
set linetype 20 lc rgb 'orange' lw temp_lw pt 10 ps 1  # orange bright triangle (mirror) nofill, etc
set linetype 21 lc rgb 'violet' lw temp_lw pt 7 ps 1  # purple bright circle, etc
set linetype 22 lc rgb 'cyan' lw temp_lw pt 7 ps 1  # cyan bright circle, etc
set linetype 23 lc 8 lw temp_lw/2 # thin black for margins, etc

set output 'demo.png'; test

###### MACROS ######

# run as @macro_name
setlogx = "set logscale x; set format x '10^{%L}'"
unsetlogx = "unset logscale x; unset format x; set xtics"
setlogy = "set logscale y; set format y '10^{%L}'"
unsetlogy = "unset logscale y; unset format y; set ytics"

###### OPTIONS ######

# set border lw 2
# set grid xtics ytics back lw 1 lc 8
# set grid mxtics mytics
# set key box lt 14

# set datafile separator ','
set fit quiet errorvariables
# set fit results

# set key font ',24'

# set format x '%.2t.10^{%L}'
# set format y '%.2t.10^{%L}'

###### COMMAND LINE ARGUMENTS ######

if (!exists("filename")) { print "No filename given!"; exit}
if (!exists("xlab")) { xlab='x' }
if (!exists("ylab")) { ylab='y' }
if (exists("xtic")) { set xtics xtic }
if (exists("ytic")) { set ytics ytic }
if (!exists("xsci")) { xsci=0 }
if (!exists("ysci")) { ysci=0 }
if (!exists("runavg")) { runavg=0 }
if (!exists("doubleplot")) { numfiles=1 }
if (exists("doubleplot")) { numfiles=2 }

set yrange [] writeback
set xrange [] writeback
if (exists("xmin") && exists("xmax")) { set xrange [xmin:xmax] writeback }
if (exists("xmin") && !exists("xmax")) { set xrange [xmin:] writeback }
if (!exists("xmin") && exists("xmax")) { set xrange [:xmax] writeback }
if (exists("ymin") && exists("ymax")) { set yrange [ymin:ymax] writeback }
if (exists("ymin") && !exists("ymax")) { set yrange [ymin:] writeback }
if (!exists("ymin") && exists("ymax")) { set yrange [:ymax] writeback }

if (!exists("constfit")) { constfit=0 }

###### PLOTS ######

set datafile commentschars "#@&" # for xvg

set rmargin at screen 0.95

if (exists("output")) {
  set output output.'.png'
} else {
  set output filename.'.png'
}

set xlabel xlab
set ylabel ylab
if (xsci==1) set format x '%.2t.10^{%S}'
if (ysci==1) set format y '%.2t.10^{%S}'

if (numfiles==1) {

  set multiplot

  if (constfit==1) {
    c(x) = c1
    if ( exists("fitmin") &&  exists("fitmax")) { fit [fitmin:fitnmax] c(x) filename.'.xvg' u 1:2 via c1}
    if ( exists("fitmin") && !exists("fitmax")) { fit [fitmin:] c(x) filename.'.xvg' u 1:2 via c1}
    if (!exists("fitmin") &&  exists("fitmax")) { fit [:fitnmax] c(x) filename.'.xvg' u 1:2 via c1}
    if (!exists("fitmin") && !exists("fitmax")) { fit c(x) filename.'.xvg' u 1:2 via c1}
  }

  plot filename.'.xvg' using 1:2 with lines lw 2 notitle

  if (runavg==1) { 
    set yrange restore
    samples(x) = $0 > 4 ? 5 : ($0+1)
    avg5(x) = (shift5(x), (back1+back2+back3+back4+back5)/samples($0))
    shift5(x) = (back5 = back4, back4 = back3, back3 = back2, back2 = back1, back1 = x)
    init(x) = (back1 = back2 = back3 = back4 = back5 = sum = 0)
    set termoption dashed
    plot sum = init(0), filename.'.xvg' u 1:(avg5($2)) t 'running average (5 steps)' w l ls 10
  }

  if (constfit==1) {
    set yrange restore
    set xrange restore
    plot c1 t 'fit' w l ls 10
    if ( exists("fitmin") &&  exists("fitmax")) { plot [fitmin:fitnmax] c1 t 'fit' w l ls 10 }
    if ( exists("fitmin") && !exists("fitmax")) { plot [fitmin:] c1 t 'fit' w l ls 10 }
    if (!exists("fitmin") &&  exists("fitmax")) { plot [:fitnmax] c1 t 'fit' w l ls 10 }
    if (!exists("fitmin") && !exists("fitmax")) { plot c1 t 'fit' w l ls 10 }
    set termoption dashed
    plot c1+c1_err w l ls 10 notitle
    plot c1-c1_err w l ls 10 notitle
    if ( exists("fitmin") &&  exists("fitmax")) { plot [fitmin:fitnmax] c1+c1_err t 'fit' w l ls 10; plot [fitmin:fitnmax] c1-c1_err t 'fit' w l ls 10 }
    if ( exists("fitmin") && !exists("fitmax")) { plot [fitmin:] c1+c1_err t 'fit' w l ls 10; plot [fitmin:] c1-c1_err t 'fit' w l ls 10 }
    if (!exists("fitmin") &&  exists("fitmax")) { plot [:fitnmax] c1+c1_err t 'fit' w l ls 10; plot [:fitnmax] c1-c1_err t 'fit' w l ls 10 }
    if (!exists("fitmin") && !exists("fitmax")) { plot c1+c1_err t 'fit' w l ls 10; plot c1-c1_err t 'fit' w l ls 10 }
    set label 1 sprintf('avg = (%4.2f +/- %4.2f)',c1,c1_err) at graph 0.3,0.1
  }

}

if (numfiles==2) {

  set key bottom right reverse Left

  if (!exists("filename2")) { print "Second filename missing!"; exit }
  if (!exists("title1")) { print "First title missing!" }
  if (!exists("title2")) { print "Second title missing!" }

  plot filename.'.xvg' u 1:2 w l lw 2 t title1,\
       filename2.'.xvg' u 1:2 w l lw 2 t title2
}