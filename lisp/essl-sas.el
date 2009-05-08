;;; essl-sas.el --- SAS customization

;; Copyright (C) 1997--2008 A.J. Rossini, Rich M. Heiberger, Martin
;;	Maechler, Kurt Hornik, Rodney Sparapani, and Stephen Eglen.

;; Original Authors: Richard M. Heiberger <rmh@astro.ocis.temple.edu>,
;;          A.J. Rossini <rossini@u.washington.edu>,
;;          Rodney Sparapani <rsparap@mcw.edu>
;; Created: 20 Aug 1997
;; Maintainers: ESS-core <ESS-core@stat.math.ethz.ch>

;; Keywords: start up, configuration.

;; This file is part of ESS (Emacs Speaks Statistics).

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:
;;; This is based upon Version 1.4 of SAS mode:


;;;    sas-mode:  indent, run etc, SAS programs.
;;;    Copyright (C) 1994--1997 Tom Cook
;;;  Author:   Tom Cook
;;;            Dept. of Biostatistics
;;;            University of Wisconsin - Madison
;;;            Madison, WI 53706
;;;            cook@biostat.wisc.edu
;;;
;;;  Acknowledgements:
;;;  Menu code for XEmacs/Lucid emacs and startup mods
;;;  contributed by arossini@biostats.hmc.psu.edu
;;;
;;; Last change: 2/1/95
;;; Last change: 01/15/02

(ess-message "[essl-sas:] (require 'ess) ...")
(require 'ess)
(ess-message "[essl-sas:] (require 'ess-mode) ...")
(require 'ess-mode)
(require 'ess-cust)

(ess-message "[essl-sas:] (autoload ..) (def** ..) etc ...")

(autoload 'ess-transcript-mode "ess-trns" "ESS source eval mode." t)

(put 'ess-transcript-minor-mode 'permanent-local t)
(or (assq 'ess-transcript-minor-mode minor-mode-alist)
    (setq minor-mode-alist
	  (append minor-mode-alist
		  (list '(ess-transcript-minor-mode " ESStr")))))

(put 'ess-listing-minor-mode 'permanent-local t)
(or (assq 'ess-listing-minor-mode minor-mode-alist)
    (setq minor-mode-alist
	  (append minor-mode-alist
		  (list '(ess-listing-minor-mode " ESSlst")))))

(defun ess-transcript-minor-mode (&optional arg)
  "Toggle Ess-Transcript minor mode.
With arg, turn Ess-Transcript minor mode on if arg is positive, off
otherwise.  See the command `ess-transcript-mode' for more information
on this mode."
  (interactive "P")
  (setq ess-transcript-minor-mode
	(if (null arg) (not ess-transcript-minor-mode)
	  (> (prefix-numeric-value arg) 0)))
  (force-mode-line-update)
  (setq mode-line-process
	'(" [" ess-local-process-name "]")))

(defun ess-listing-minor-mode (&optional arg)
  "Toggle Ess-Listing minor mode.
With arg, turn Ess-Listing minor mode on if arg is positive, off
otherwise.  Ess-Listing mode is used solely to place an indicator on
the mode line."
  (interactive "P")
  (setq ess-listing-minor-mode
	(if (null arg) (not ess-listing-minor-mode)
	  (> (prefix-numeric-value arg) 0)))
  (force-mode-line-update)
  (setq mode-line-process
	'(" [" ess-local-process-name "]")))

(defun SAS-log-mode ()
  "`ess-transcript-mode' for SAS."
  (interactive)
  (SAS-mode)
  (ess-transcript-minor-mode 1)
  (toggle-read-only t)) ;; to protect the buffer.

(defun SAS-listing-mode()
  "Fundamental mode with `ess-listing-minor-mode' and read-only."
  (interactive)
  (fundamental-mode)
  (ess-listing-minor-mode 1)
  (use-local-map sas-mode-local-map)
  (toggle-read-only t)) ;; to protect the buffer.

(fset 'sas-log-mode        'SAS-log-mode)
(fset 'SAS-transcript-mode 'SAS-log-mode)
(fset 'sas-transcript-mode 'SAS-log-mode)
(fset 'sas-mode 'SAS-mode)
(fset 'sas-listing-mode    'SAS-listing-mode)

(defcustom  sas-indent-width 4
  "*Amount to indent sas statements."
  :group 'ess-sas
  :type  'integer)

(defcustom sas-indent-ignore-comment "*"
  "*Comments that start with this string are ignored in indentation."
  :group 'ess-sas
  :type  'string)

(defcustom sas-require-confirmation t
  "*Require confirmation when revisiting a modified sas-output file."
  :group 'ess-sas
  :type  'boolean)

;; user can specify the sas program name
(defcustom sas-program
  (if (equal system-type 'Apple-Macintosh) "invoke SAS using program file" "sas")
  "*Command to invoke SAS, default for buffer-local `ess-sas-submit-command'."
  :group 'ess-sas
  :type  'string)

(defcustom sas-pre-run-hook nil
  "Hook to execute prior to running SAS via `submit-sas'."
  :group 'ess-sas
  :type  'hook)

;never used--see ess-sas-submit-command-options in essa-sas.el
;(defcustom sas-options-string ""
;  "*Options to be passed to sas as if typed on the command line."
;  :group 'ess-sas
;  :type  'string)

(defcustom sas-notify t
  "*Beep and display message when job is done."
  :group 'ess-sas
  :type  'boolean)

(defcustom sas-error-notify t
  "*If `sas-notify' t, indicate errors in log file upon completion."
  :group 'ess-sas
  :type  'boolean)

(defcustom sas-get-options nil
  "Options to be passed to SAS in sas-get-dataset."
  :group 'ess-sas
  :type '(choice (const nil) string))

(defcustom sas-get-options-history nil
  "History list of Options passed to SAS in sas-get-dataset."
  :group 'ess-sas)

(defcustom sas-page-number-max-line 3
  "*Number of lines from the page break, to search for the page
number."
  :group 'ess-sas
  :type  'integer)

(defcustom sas-notify-popup nil
  "*If this and sas-notify are t), popup a window when SAS job ends."
  :group 'ess-sas
  :type  'boolean)

(defcustom sas-tmp-libname "_tmp_"
  "*Libname to use for sas-get-dataset."
  :group 'ess-sas
  :type  'string)

(defcustom sas-file-name nil
  "*The name of the current sas file."
  :group 'ess-sas
  :type '(choice (const nil) file))

;; The next two are ``the inside of [...] in a regexp'' to be used in
;; (skip-chars-(for|back)ward SAS-..-chars)
(defcustom sas-white-chars " \t\n\f"
  "This does NOT escape blanks (RMH, 2000/03/20)."
  :group 'ess-sas
  :type  'string)

(defcustom sas-comment-chars (concat sas-white-chars ";")
  "Doc?"
  :group 'ess-sas
  :type  'string)

(defcustom ess-sas-run-regexp-opt nil
  "If you do not want to run regexp-opt, then set to nil."
  :group 'ess-sas
  :type '(choice (const nil) string))

(require 'essa-sas)

(defvar sas-buffer-name nil)
(defvar sas-file-root nil)
(defvar sas-submitable nil)
(defvar sas-dataset nil)
(defvar SAS-syntax-table nil "Syntax table for SAS code.")

(if SAS-syntax-table nil
  (setq SAS-syntax-table (make-syntax-table))

;; (if (equal system-type 'windows-nt)
;;     ;; backslash is punctuation (used in MS file names)
;;     (modify-syntax-entry ?\\ "."  SAS-syntax-table)
;;    ;; backslash is an escape character
;;    (modify-syntax-entry ?\\ "\\" SAS-syntax-table))
(modify-syntax-entry ?\\ "."  SAS-syntax-table)  ;; backslash is punctuation
(modify-syntax-entry ?+  "."  SAS-syntax-table)
(modify-syntax-entry ?-  "."  SAS-syntax-table)
(modify-syntax-entry ?=  "."  SAS-syntax-table)
(modify-syntax-entry ?%  "w"  SAS-syntax-table)
(modify-syntax-entry ?<  "."  SAS-syntax-table)
(modify-syntax-entry ?>  "."  SAS-syntax-table)
(modify-syntax-entry ?&  "w"  SAS-syntax-table)
(modify-syntax-entry ?|  "."  SAS-syntax-table)
(modify-syntax-entry ?\' "\"" SAS-syntax-table)
(modify-syntax-entry ?*  ". 23"  SAS-syntax-table) ; comment character
(modify-syntax-entry ?\; "."  SAS-syntax-table)
(modify-syntax-entry ?_  "w"  SAS-syntax-table)
(modify-syntax-entry ?<  "."  SAS-syntax-table)
(modify-syntax-entry ?>  "."  SAS-syntax-table)
(modify-syntax-entry ?/  ". 14"  SAS-syntax-table) ; comment character
(modify-syntax-entry ?.  "w"  SAS-syntax-table))

(require 'font-lock); fontification also works in terminals!
;; (if (or window-system
;;  	noninteractive) ; compilation!
;;; ...


(defvar SAS-mode-font-lock-keywords
  (if ess-sas-run-regexp-opt
      (list
       ;; old SAS comment code
;       (cons "^[ \t]*%?\\*.*;"		font-lock-comment-face)
;       (cons ";[ \t]*%?\\*.*;"		font-lock-comment-face)
;       (list "/\\*\\([^*/]\\)*\\*/"      0  font-lock-comment-face t)
    
     ;; .log NOTE: messages
     (cons "^NOTE: .*$"                         font-lock-constant-face)
     (cons "This may cause NOTE: No observations in data set."     
						font-lock-constant-face)

     ;; .log ERROR: messages
     (cons "^ERROR .*$"                         font-lock-keyword-face)

     ;; .log WARNING: messages
     (cons "^WARNING: .*$"                      font-lock-function-name-face)

     ;; SAS comments
     ;; /* */ handled by grammar above
     (cons "\\(^[0-9]*\\|;\\)[ \t]*\\(%?\\*\\|comment\\).*\\(;\\|$\\)" font-lock-comment-face)
    
     ; this exception needs to come before "data" below
     (cons "data=" font-lock-keyword-face)

; SAS procedure names circa v. 9.2
; this code doesn't actually work, but why ?!?
;
;       (cons (concat "proc" (regexp-opt '(
;		    "append"
;		    "bgenmod" "blifereg" "bphreg"
;		    "genmod" "lifereg" "phreg" "tphreg"
;		    "calendar" "catalog" "cport" "compare" "contents" "copy" "corr" 
;		    "cimport" "gimport" "import" 
;		    "datasets" "dbcstab" "display"
;		    "explode" "export"
;		    "format" "forms" "freq" "fsbrowse" "fsedit" "fsletter" "fslist" "fsview"
;		    "gchart" "gplot" "gprint" 
;		    "chart" "plot" "print" 
;		    "ganno" "gcontour" "gdevice" "geocode" "gfont" "ginside"
;		    "gkeymap" "gmap" 
;		    "goptions" "options"
;		    "gproject" "greduce" "gremove" "greplay" "gslide"
;		    "gtestit" "g3d" "g3grid" 
;		    "iml" "insight"
;		    "mapimport" "means"
;		    "pmenu" "printto"
;		    "rank" "registry" "report"
;		    "sort" "sql" "standard" "summary"
;		    "tabulate" "template" "timeplot" "transpose" "trantab"
;		    "univariate"
;		   ;;SAS/Stat and SAS/ETS
;		    "aceclus" "anova" "arima" "autoreg"
;		    "boxplot"
;		    "calis" "cancorr" "candisc" "catmod" "citibase" "cluster" "computab" "corresp"
;		    "discrim"
;		    "expand"
;		    "factor" "fastclus" "forecast"
;		    "glimmix" "glm" "glmmod" "glmpower" "glmselect"
;		    "inbreed"
;		    "kde" "krige2d"
;		    "lattice" "lifetest" "loess" "logistic"
;		    "mds" "mixed" "modeclus" "model" "mortgage" "multtest"
;		    "nested" "nlin" "nlmixed" "npar1way"
;		    "orthoreg"
;		    "pdlreg" "plan" "pls" "power" "princomp" "prinqual" "probit"
;		    "reg" "rsreg"
;		    "score" "sim2d" "simlin" "spectra" "statespace" "stdize" "stepdisc" 
;		    "surveymeans" "surveyreg" "surveyselect" "syslin"
;		    "tpspline" "transreg" "tree" "ttest"
;		    "varclus" "varcomp" "variogram"
;		    "x11"
;		) 'words)) font-lock-constant-face)
  
       ;; SAS execution blocks, DATA/RUN, PROC/RUN, %MACRO/%MEND, etc.
       (cons (regexp-opt '(
		 "data" "run" "proc" "endsas" "%macro" "%mend"
		 "%do" "%to" "%by" "%end" 
		 "%goto" "%go to" 
		 "%if" "%then" "%else"
		 "%global" "%include" "%input" "%local" "%let" "%put" "%sysexec"
	    ) 'words) font-lock-constant-face)
    
       ;; SAS statements

       (cons (concat
	      "\\<"
	      "do[ \t]*" (regexp-opt '("over" "until" "while") t) "?"
	      "\\>")
	     font-lock-keyword-face)

       (cons (concat
	      ;"\\<"
	      (regexp-opt
	       '(
		"abort" "array" "attrib" 
		"by" 
		"change" "class" 
		"delete" "display" "dm" "drop"
		"else" "error" "exchange" "exclude" 
		"file" "filename" "format" "freq"
		 "footnote" "footnote1" "footnote2" "footnote3" "footnote4" "footnote5" 
		 "footnote6" "footnote7" "footnote8" "footnote9" "footnote10"
		"goto" "go to" "goptions"
		"id" "if" "in" "index" "infile" "informat" "input" 
		"keep" 
		"label" "length" "libname" "link" "lsmeans"
		"manova" "means" "model" "merge" "missing" "modify" 
		"note" 
		"options" "out" "output" "otherwise" 
		"plot" "put" 
		"random" "rename" "repeated" "retain" 
		"save" "select" "set" "skip" "sum"
		"table" "tables" "then" 
		 "title" "title1" "title2" "title3" "title4" "title5" 
		 "title6" "title7" "title8" "title9" "title10"
		"weight" "where" "window" "with" 
		"update"
		"value" "var"
		"x"
		 ) 'words)) ;"\\>")
	     font-lock-keyword-face)

       ;; SAS statements that must be followed by a semi-colon
       (cons (concat
	      ;"\\<"
	      (regexp-opt
	       '(
		 "cards" "cards4" "end" "list" "lostcard" "page"
		 "return" "stop"
		 ) 'words) ;"\\>" 
		"[ \t]*;")
	     font-lock-keyword-face)

       ;; SAS/GRAPH statements not handled above
       (cons (concat
	      ;"\\<"
	      (regexp-opt
	       '("axis" "legend" "pattern" "symbol") 'words) "\\([1-9][0-9]?\\)?"
	      ) ;"\\>")
	     font-lock-keyword-face)

       ;; SAS functions and SAS macro functions
       (cons "%[a-z_][a-z_0-9]*[ \t]*[(;]"
	     font-lock-function-name-face)
       (cons "\\<call[ \t]+[a-z_][a-z_0-9]*[ \t]*("
	     font-lock-function-name-face)

       (cons (concat
	      ;"\\<"
	      (regexp-opt
	       '(
		 "abs" "arcos" "arsin" "atan" "betainv" "byte" "ceil" "cinv"
		 "collate" "compress" "cos" "cosh" "css" "cv"
		 "daccdb" "daccdbsl" "daccsl" "daccsyd" "dacctab"
		 "depdb" "depdbsl" "depsl" "depsyd" "deptab"
		 "date" "datejul" "datepart" "datetime" "day" "hms" "dhms" "dif"
		 "digamma" "dim" "erf" "erfc" "exp" "finv"
		 "fipname" "fipnamel" "fipstate" "floor" "fuzz" "gaminv" "gamma"
		 "hbound" "hour" "in" "index" "indexc" "input" "int" "intck" "intnx" "intrr"
		 "irr" "juldate" "kurtosis" "lag" "lbound" "left" "length"
		 "lgamma" "log" "log10" "log2" "max" "mdy" "mean" "min" "minute"
		 "mod" "month" "mort" "n" "netpv" "nmiss" "not" "normal" "npv"
;;;) t) "\\>" "[ \t]*(")
;;;      font-lock-function-name-face)
;;;
;;;    (cons (concat "\\<"
;;;(regexp-opt '(
		 "probbeta" "probbnml" "probchi" "probf" "probgam" "probhypr"
		 "probit" "probnegb" "probnorm" "probt"
		 "ordinal" "poisson" "put" "qtr" "range" "rank" "repeat"
		 "ranbin" "rancau" "ranexp" "rangam" "rannor" "ranpoi"
		 "rantbl" "rantri" "ranuni"
		 "reverse" "right" "round" "saving" "scan" "second" "sign" "sin" "sinh"
		 "sqrt" "std" "stderr" "stfips" "stname" "stnamel" "substr" "sum"
		 "symget" "tan" "tanh" "time" "timepart" "tinv" "today" "translate"
		 "trigamma" "trim" "trunc" "uniform" "upcase" "uss" "var"
		 "verify" "weekday" "when" "year" "yyq"
		 "zipfips" "zipname" "zipnamel" "zipstate"
;;;) t) "\\>" "[ \t]*(")
;;;      font-lock-function-name-face)
;;;
;;;
;;;    ;; SAS functions introduced in Technical Report P-222
;;;    ;; SCL functions that are known to work with SAS macro function %sysfunc
;;;    (cons (concat "\\<"
;;;(regexp-opt '(
		 "airy" "band" "blshift" "brshift" "bnot" "bor" "bxor"
		 "cnonct" "fnonct" "tnonct" "compbl" "dairy" "dequote"
		 "ibessel" "jbessel"
		 "indexw" "inputc" "inputn"  "lowcase"
		 "putc" "putn" "quote" "resolve" "soundex" "sysprod"
		 "tranwrd" "trimn"
		 "%sysfunc" "attrc" "attrn" "cexist" "close" "dclose" "dnum"
		 "dopen" "dread" "exist" "fclose" "fetchobs" "fileexist"
		 "finfo" "fopen" "fput" "fwrite" "getoption"
		 "getvarc" "getvarn" "libname" "libref" "open" "optgetn" "optsetn"
		 "pathname" "sysmsg" "varfmt" "varlabel" "varnum" "vartype"
		 ) 'words) ;"\\>" 
		"[ \t]*(")
	     font-lock-function-name-face)
       )
    (list
     ;; .log NOTE: messages
     (cons "^NOTE: .*$"                         font-lock-constant-face)

     ;; .log ERROR: messages
     (cons "^ERROR: .*$"                        font-lock-keyword-face)

     ;; .log WARNING: messages
     (cons "^WARNING: .*$"                      font-lock-function-name-face)

     ;; SAS comments
     ;; /* */ handled by grammar above
     ;;	 (list "/\\*.*\\*/"                      0  font-lock-comment-face t)
     (cons "\\(^[0-9]*\\|;\\)[ \t]*\\(%?\\*\\|comment\\).*\\(;\\|$\\)" font-lock-comment-face)

     ;; SAS execution blocks, DATA/RUN, PROC/RUN, SAS Macro Statements
     (cons "\\<%do[ \t]*\\(%until\\|%while\\)?\\>"
	   font-lock-constant-face)
     ;;(cons (concat "\\(^[0-9]*\\|;\\)[ \t]*"
     ;;"%\\(end\\|global\\|local\\|m\\(acro\\|end\\)\\)"
     ;;"\\>")				    font-lock-constant-face)
     (cons "\\<%\\(end\\|global\\|local\\|m\\(acro\\|end\\)\\)\\>"
	   font-lock-constant-face)

     (cons (concat "\\(^[0-9]*\\|;\\|):\\|%then\\|%else\\)[ \t]*"
		   "\\(data\\|endsas\\|finish\\|quit\\|run\\|start\\)[ \t\n;]")
	   font-lock-constant-face)
     (cons (concat "\\(^[0-9]*\\|;\\|):\\|%then\\|%else\\)[ \t]*"
		   ;;"proc[ \t]+[a-z][a-z_0-9]+")        font-lock-constant-face)
		   "proc[ \t]+"
		   ;;SAS/Base, SAS/Graph, SAS/FSP and common add-ons
		   "\\(append"
		   "\\|b\\(genmod\\|lifereg\\|phreg\\)"
		   "\\|c\\(a\\(lendar\\|talog\\)\\|port\\|o\\(mpare\\|ntents\\|py\\|rr\\)\\)"
		   "\\|d\\(atasets\\|bcstab\\|isplay\\)\\|ex\\(plode\\|port\\)"
		   "\\|f\\(orm\\(at\\|s\\)\\|req\\|s\\(browse\\|edit\\|l\\(etter\\|ist\\)\\|view\\)\\)"
		   "\\|g?\\(chart\\|p\\(lot\\|rint\\)\\)"
		   "\\|g\\(anno\\|contour\\|device\\|font\\|\\(key\\)?map\\|options\\|project"
		   "\\|re\\(duce\\|move\\|play\\)\\|slide\\|testit\\|3\\(d\\|grid\\)\\)"
		   "\\|\\(map\\|[cg]\\)?import\\|i\\(ml\\|nsight\\)"
		   "\\|means\\|options\\|p\\(menu\\|rintto\\)"
		   "\\|r\\(ank\\|e\\(gistry\\|port\\)\\)"
		   "\\|s\\(ort\\|ql\\|tandard\\|ummary\\)"
		   "\\|t\\(abulate\\|emplate\\|imeplot\\|ran\\(spose\\|tab\\)\\)\\|univariate"
		   ;;SAS/Stat and SAS/ETS
		   "\\|a\\(ceclus\\|nova\\|rima\\|utoreg\\)\\|boxplot"
		   "\\|c\\(a\\(lis\\|n\\(corr\\|disc\\)\\|tmod\\)\\|itibase\\|luster\\|o\\(mputab\\|rresp\\)\\)"
		   "\\|discrim\\|expand\\|f\\(a\\(ctor\\|stclus\\)\\|orecast\\|req\\)"
		   "\\|g\\(enmod\\|l\\(immix\\|m\\(mod\\|power\\|select\\)?\\)\\)\\|inbreed\\|k\\(de\\|rige2d\\)"
		   "\\|l\\(attice\\|ife\\(reg\\|test\\)\\|o\\(ess\\|gistic\\)\\)"
		   "\\|m\\(ds\\|ixed\\|o\\(de\\(clus\\|l\\)\\|rtgage\\)\\|ulttest\\)"
		   "\\|n\\(ested\\|l\\(in\\|mixed\\)\\|par1way\\)\\|orthoreg"
		   "\\|p\\(dlreg\\|hreg\\|l\\(an\\|s\\)\\|ower\\|r\\(in\\(comp\\|qual\\)\\|obit\\)\\)\\|r\\(sr\\)?eg"
		   "\\|s\\(core\\|im\\(2d\\|lin\\)\\|pectra\\|t\\(atespace\\|dize\\|epdisc\\)\\|urvey\\(means\\|reg\\|select\\)\\|yslin\\)"
		   "\\|t\\(phreg\\|pspline\\|r\\(ansreg\\|ee\\)\\|test\\)"
		   "\\|var\\(clus\\|comp\\|iogram\\)\\|x11"
		   "\\)")        font-lock-constant-face)

     ;;(cons (concat "\\(^[0-9]*\\|;\\|%then\\|%else\\)[ \t]*"
     ;;"\\(%\\(go[ \t]*to\\|i\\(f\\|n\\(clude\\|put\\)\\)\\|let\\|put\\|sysexec\\)\\)"
     ;;"\\>")				    font-lock-constant-face)
     (cons "\\<%\\(go[ \t]*to\\|i\\(f\\|n\\(clude\\|put\\)\\)\\|let\\|put\\|sysexec\\)\\>"
	   font-lock-constant-face)

     (cons "\\<%\\(by\\|else\\|t\\(o\\|hen\\)\\)\\>"
	   font-lock-constant-face)

     ;; SAS dataset options/PROC statements followed by an equal sign/left parentheses

     (cons (concat
	    "[ \t(,]"
	    "\\(attrib\\|by\\|compress\\|d\\(ata\\|rop\\)\\|f\\(irstobs\\|ormat\\)"
	    "\\|i\\(d\\|f\\|n\\)\\|ke\\(ep\\|y\\)\\|l\\(abel\\|ength\\)"
	    "\\|o\\(bs\\|rder\\|ut\\)\\|rename\\|s\\(ortedby\\|plit\\)"
	    "\\|var\\|where\\)"
	    "[ \t]*=")
	   font-lock-keyword-face)
     (cons "\\<\\(in\\(:\\|dex[ \t]*=\\)?\\|until\\|wh\\(en\\|ile\\)\\)[ \t]*("
	   font-lock-keyword-face)

     ;; SAS statements
     (cons (concat
	    "\\(^[0-9]*\\|):\\|[;,]\\|then\\|else\\)[ \t]*"
	    "\\(a\\(bort\\|rray\\|ttrib\\)\\|b\\(ayes\\|y\\)"
	    "\\|c\\(hange\\|lass\\|ontrast\\)"
	    "\\|d\\(elete\\|isplay\\|m\\|o\\([ \t]+\\(data\\|over\\)\\)?\\|rop\\)"
	    "\\|e\\(rror\\|stimate\\|xc\\(hange\\|lude\\)\\)"
	    "\\|f\\(ile\\(name\\)?\\|o\\(otnote\\(10?\\|[2-9]\\)?\\|rmat\\)\\|req\\)"
	    "\\|go\\([ \t]*to\\|ptions\\)"
	    "\\|hazardratio\\|[hv]bar\\(3d\\)?"
	    "\\|i\\(d\\|f\\|n\\(dex\\|f\\(ile\\|ormat\\)\\|put\\|value\\)\\)"
	    "\\|keep\\|l\\(abel\\|ength\\|i\\(bname\\|nk\\|st\\)\\|smeans\\)"
	    "\\|m\\(anova\\|e\\(ans\\|rge\\)\\|issing\\|od\\(el\\|ify\\)\\)\\|note"
	    "\\|o\\(ds\\|ptions\\|therwise\\|utput\\)\\|p\\(arms\\|lot2?\\|ut\\)"
	    "\\|r\\(andom\\|e\\(name\\|peated\\|tain\\)\\)"
	    "\\|s\\(ave\\|e\\(lect\\|t\\)\\|kip\\|trata\\|um\\(by\\)?\\)"
	    "\\|t\\(ables?\\|i\\(me\\|tle\\(10?\\|[2-9]\\)?\\)\\)\\|update"
	    "\\|va\\(lue\\|r\\)\\|w\\(eight\\|here\\|i\\(ndow\\|th\\)\\)"

	    ;; IML statements that are not also SAS statements
	    "\\|append\\|c\\(lose\\(file\\)?\\|reate\\)\\|edit\\|f\\(ind\\|orce\\|ree\\)"
	    "\\|insert\\|load\\|mattrib\\|p\\(a[ru]se\\|rint\\|urge\\)"
	    "\\|re\\(move\\|peat\\|place\\|set\\|sume\\)"
	    "\\|s\\(et\\(in\\|out\\)\\|how\\|ort\\|tore\\|ummary\\)\\|use\\)?"

	    "\\>")				    font-lock-keyword-face)



     ;;	 (cons "\\<\\(\\(then\\|else\\)[ \t]*\\)?\\(do\\([ \t]*over\\)?\\|else\\)\\>"
     ;;						    font-lock-keyword-face)

     ;; SAS statements that must be followed by a semi-colon
     (cons (concat
	    "\\(^[0-9]*\\|):\\|[;,]\\|then\\|else\\)[ \t]*"
	    "\\(cards4?\\|datalines\\|end\\|l\\(ostcard\\)\\|page\\|return\\|stop\\)?"
	    "[ \t]*;")			    font-lock-keyword-face)

     ;; SAS/GRAPH statements not handled above
     (cons (concat
	    "\\(^[0-9]*\\|):\\|[;,]\\)[ \t]*"
	    "\\(axis\\|legend\\|pattern\\|symbol\\)"
	    "\\([1-9][0-9]?\\)?\\>")	    font-lock-keyword-face)

     ;; SAS Datastep functions and SAS macro functions
					;(cons "%[a-z_][a-z_0-9]*[ \t]*[(;]"
     ;; SAS macro functions occasionally defined with no arguments
     ;; which means they can be followed by any character that can
     ;; separate tokens, however, they are most likely to be followed
     ;; by operat-ions/ors
     (cons "%[a-z_][a-z_0-9]*[- \t();,+*/=<>]"
	   font-lock-function-name-face)
     (cons "\\<call[ \t]+[a-z_][a-z_0-9]*[ \t]*("
	   font-lock-function-name-face)

     (cons (concat
	    "\\<"
	    "\\(a\\(bs\\|r\\(cos\\|sin\\)\\|tan\\)\\|b\\(etainv\\|yte\\)"
	    "\\|c\\(eil\\|inv\\|o\\(llate\\|mpress\\|sh?\\)\\|ss\\|v\\)"
	    "\\|dacc\\(db\\(\\|sl\\)\\|s\\(l\\|yd\\)\\|tab\\)"
	    "\\|dep\\(db\\(\\|sl\\)\\|s\\(l\\|yd\\)\\|tab\\)"
	    "\\|d\\(a\\(te\\(\\|jul\\|part\\|time\\)\\|y\\)\\|hms\\|i\\(f[0-9]*\\|m\\|gamma\\)\\)"
	    "\\|e\\(rfc?\\|xp\\)"
	    "\\|f\\(i\\(nv\\|p\\(namel?\\|state\\)\\)\\|loor\\|uzz\\)\\|gam\\(inv\\|ma\\)"
	    "\\|h\\(bound\\|ms\\|our\\)\\|i\\(n\\(dexc?\\|put\\|t\\(\\|ck\\|nx\\|rr\\)\\)\\|rr\\)"
	    "\\|juldate\\|kurtosis\\|l\\(ag[0-9]*\\|bound\\|e\\(ft\\|ngth\\)\\|gamma\\|og\\(\\|10\\|2\\)\\)"
	    "\\|m\\(ax\\|dy\\|ean\\|in\\(\\|ute\\)\\|o\\(d\\|nth\\|rt\\)\\)"
	    "\\|n\\(\\|etpv\\|miss\\|o\\(rmal\\|t\\)\\|pv\\)"
	    "\\|prob\\([ft]\\|b\\(eta\\|nml\\)\\|chi\\|gam\\|hypr\\|it\\|n\\(egb\\|orm\\)\\)"
	    "\\|ordinal\\|p\\(oisson\\|ut\\)\\|qtr\\|r\\(e\\(peat\\|verse\\)\\|ight\\|ound\\)"
	    "\\|ran\\(bin\\|cau\\|exp\\|g\\(am\\|e\\)\\|k\\|nor\\|poi\\|t\\(bl\\|ri\\)\\|uni\\)"
	    "\\|s\\(aving\\|can\\|econd\\|i\\(gn\\|nh?\\)\\|qrt\\|t\\(d\\(\\|err\\)\\|fips\\|namel?\\)\\|u\\(bstr\\|m\\)\\|ymget\\)"
	    "\\|t\\(anh?\\|i\\(me\\(\\|part\\)\\|nv\\)\\|oday\\|r\\(anslate\\|i\\(gamma\\|m\\)\\|unc\\)\\)"
	    "\\|u\\(niform\\|pcase\\|ss\\)\\|v\\(ar\\|erify\\)"
	    "\\|weekday\\|y\\(ear\\|yq\\)\\|zip\\(fips\\|namel?\\|state\\)"

;;;    ;; SAS functions introduced in Technical Report P-222

	    "\\|airy\\|b\\(and\\|lshift\\|not\\|or\\|rshift\\|xor\\)"
	    "\\|c\\(nonct\\|ompbl\\)\\|d\\(airy\\|equote\\)\\|fnonct\\|tnonct"
	    "\\|i\\(bessel\\|n\\(dexw\\|put[cn]\\)\\)\\|jbessel\\|put[cn]"
	    "\\|lowcase\\|quote\\|resolve\\|s\\(oundex\\|ysprod\\)\\|tr\\(anwrd\\|imn\\)"

;;;    ;; IML functions that are not also Datastep functions
	    "\\|a\\(ll\\|ny\\|pply\\|rmasim\\)\\|b\\(lock\\|ranks\\|tran\\)"
	    "\\|c\\(har\\|hoose\\|on\\(cat\\|tents\\|vexit\\|vmod\\)\\|ovlag\\|shape\\|usum\\|vexhull\\)"
	    "\\|d\\(atasets\\|esignf?\\|et\\|iag\\|o\\|uration\\)"
	    "\\|e\\(chelon\\|igv\\(al\\|ec\\)\\)\\|f\\(ft\\|orward\\)\\|ginv"
	    "\\|h\\(alf\\|ankel\\|dir\\|ermite\\|omogen\\)"
	    "\\|i\\(\\|fft\\|nsert\\|nv\\(updt\\)?\\)\\|j\\(\\|root\\)\\|loc\\|mad"
	    "\\|n\\(ame\\|col\\|leng\\|row\\|um\\)\\|o\\(pscal\\|rpol\\)"
	    "\\|p\\(olyroot\\|roduct\\|v\\)\\|r\\(anktie\\|ates\\|atio\\|emove\\|eturn\\|oot\\|owcatc?\\)"
	    "\\|s\\(etdif\\|hape\\|olve\\|plinev\\|pot\\|qrsym\\|ssq\\|torage\\|weep\\|ymsqr\\)"
	    "\\|t\\(\\|eigv\\(al\\|ec\\)\\|oeplitz\\|race\\|risolv\\|ype\\)"
	    "\\|uni\\(on\\|que\\)\\|v\\(alue\\|ecdiag\\)\\|x\\(mult\\|sect\\)\\|yield"

;;;    ;; SCL functions that are known to work with SAS macro function %sysfunc

	    "\\|attr[cn]\\|c\\(exist\\|lose\\)\\|d\\(close\\|num\\|open\\|read\\)"
	    "\\|exist\\|f\\(close\\|etchobs\\|i\\(leexist\\|nfo\\)\\|open\\|put\\|write\\)"
	    "\\|get\\(option\\|var[cn]\\)\\|lib\\(name\\|ref\\)\\|op\\(en\\|t\\(getn\\|setn\\)\\)"
	    "\\|pathname\\|sysmsg\\|var\\(fmt\\|l\\(abel\\|en\\)\\|n\\(ame\\|um\\)\\|type\\)\\)"
	    "[ \t]*(")			    font-lock-function-name-face)
     ))
  "Font Lock regexs for SAS.")


(defvar SAS-editing-alist
  '((sentence-end                 . ";[\t\n */]*")
    (paragraph-start              . "^[ \t]*$")
    (paragraph-separate           . "^[ \t]*$")
    (paragraph-ignore-fill-prefix . t)
    ;;(fill-paragraph-function      . 'lisp-fill-paragraph)
    (adaptive-fill-mode           . nil)
    (indent-line-function         . 'sas-indent-line)
    ;;(indent-region-function       . 'sas-indent-region)
    (require-final-newline        . t)
    (comment-start                . "/*")
    (comment-start-skip           . "/[*]")
    (comment-end                  . "*/")
    (comment-end-skip             . "[*]/")
    (comment-column               . 40)
    ;;(comment-indent-function      . 'lisp-comment-indent)
    (parse-sexp-ignore-comments   . t)
    (ess-style                . ess-default-style)
    (ess-local-process-name       . nil)
    ;;(ess-keep-dump-files          . 'ask)
    (tab-stop-list                . ess-sas-tab-stop-list)
    (ess-mode-syntax-table        . SAS-syntax-table)
    (font-lock-keywords-case-fold-search . t)
    (font-lock-defaults           . '(SAS-mode-font-lock-keywords)))
  "General options for editing SAS source files.")

(defun beginning-of-sas-statement (arg &optional comment-start)
  "Move point to beginning of current sas statement."
  (interactive "P")
  (let ((pos (point))
	)
    (if (search-forward ";" nil 1) (forward-char -1))
    (re-search-backward ";[ \n*/]*$" (point-min) 1 arg)
    (skip-chars-forward sas-comment-chars)
    (if comment-start nil
          (if (looking-at "\\*/")
              (progn (forward-char 2)
                     (skip-chars-forward sas-comment-chars)))
          (while (looking-at "/\\*")
            (if (not (search-forward "*/" pos t 1)) ;;(;; (point-max) 1 1)
                (forward-char 2))
            (skip-chars-forward sas-white-chars)))))

(defun sas-indent-line ()
  "Indent function for SAS mode."
  (interactive)
  (let (indent prev-end
               (pos (- (point-max) (point)))
               (case-fold-search t)
               (cur-ind (current-indentation))
               (comment-col (sas-comment-start-col))) ;; 2/1/95 TDC
    (save-excursion
      (cond ((progn
               (back-to-indentation)
               (or (bobp)
                   (looking-at
                    "data[ ;]\\|proc[ ;]\\|run[ ;]\\|endsas[ ;]\\|g?options[ ;]\\|%macro[ ;]\\|%mend[ ;]")))
	     ;;  Case where current statement is DATA, PROC, etc...
             (setq prev-end (point))
             (goto-char (point-min))
	     ;;  Added 6/27/94
	     ;;  May get fooled if %MACRO, %DO, etc embedded in comments
             (setq indent
		   (+ (* (- (sas-how-many "^[ \t]*%macro\\|[ \t]+%do"
					  prev-end)
			    (sas-how-many "^[ \t]*%mend\\|%end" prev-end))
			 sas-indent-width) comment-col)))  ;; 2/1/95 TDC
	    ;;  Case where current line begins with sas-indent-ignore-comment
            ;; added 6/27/94  to leave "* ;" comments alone.
            ((progn
               (back-to-indentation)
               (and (not (looking-at "*/"))
                    (looking-at (concat sas-indent-ignore-comment "\\|/\\*"))))
             (setq indent (current-indentation)))
	    ;;  Case where current statement not DATA, PROC etc...
            (t (beginning-of-line 1)
               (skip-chars-backward sas-white-chars)
               (if (bobp) nil
                 (backward-char 1))
               (cond
                ((looking-at ";")       ;  modified 1/31/95
                 (setq indent (sas-next-statement-indentation)))
                ((save-excursion;; added 4/28/94 to properly check
                   (if (bobp) () (backward-char 1));; for end of comment
                   (setq prev-end (point))
                   (looking-at "*/"));;  improved 1/31/95
                 (save-excursion
                   (search-backward "*/"
				    (point-min) 1 1); comment start is first /*
                   (search-forward "/*"
				   prev-end 1 1)    ; after previous */
                   (backward-char 2)                ; 2/1/95 TDC
                   (skip-chars-backward sas-white-chars)
                   (setq indent
                         (if (bobp) 0
                           (if (looking-at ";")
			       (sas-next-statement-indentation)
                             (+ (current-indentation) sas-indent-width))))))

		;; added 6/27/94 to leave "* ;" comments alone
		((save-excursion
		   (progn
		     (beginning-of-sas-statement 1 t)
		     (and (not (looking-at "*/"))
			  (looking-at sas-indent-ignore-comment))))
		 (setq indent cur-ind))
		((progn
		   (beginning-of-sas-statement 1)
		   (bobp));; added 4/13/94
		 (setq indent sas-indent-width));; so the first line works
		(t
		 (if (progn
		       (save-excursion
			 (beginning-of-line 1)
			 (skip-chars-backward sas-white-chars)
			 (if (bobp) nil (backward-char 1))
			 (or (looking-at ";")
			     (bobp) (backward-char 1) (looking-at "\\*/"))))
		     (setq indent (+ (current-indentation) sas-indent-width))
		   (setq indent (current-indentation))))))))
    (save-excursion
      (let (beg end)
        (back-to-indentation)
        (setq end (point))
        (beginning-of-line 1)
        (setq beg (point))
        (delete-region beg end)
        (indent-to indent)))
    (if (> (- (point-max) pos) (point))
        (goto-char (- (point-max) pos)))))


;;(defun sas-indent-region (start end)
;;  "Indent a region of SAS code."
;;  (interactive "r")
;;  (save-excursion
;;    (let ((endmark (copy-marker end)))
;;      (goto-char start)
;;      (and (bolp) (not (eolp))
;;	   (sas-indent-line))
;;      (indent-sexp endmark)
;;      (set-marker endmark nil))))


(defun indent-sas-statement (arg)
  "Indent all continuation lines sas-indent-width spaces from first
line of statement."
  (interactive "p")
  (let (end)
    (save-excursion
      (if (> arg 0)
	  (while (and (> arg 0) (search-forward ";" (point-max) 1 1))
	    (setq end (point))
	    (if (bobp) nil (backward-char 1))
	    (beginning-of-sas-statement 1)
	    (forward-char 1)
	    (indent-region (point)
			   end
			   (+ (current-column) (1- sas-indent-width)))
	    (search-forward ";" (point-max) 1 1)
	    (setq arg (1- arg)))))))

;; added 9/31/94
(defun sas-next-statement-indentation ()
  "Returns the correct indentation of the next sas statement.
The current version assumes that point is at the end of the statement.
This will (hopefully) be fixed in later versions."
  (if (bobp) 0
    (save-excursion
      (let ((prev-end (point)))
        (beginning-of-sas-statement 1)
        (while (and (not (bobp))
                    (not (looking-at "*/"))
                    (looking-at sas-indent-ignore-comment))
          (skip-chars-backward sas-white-chars)
          (if (bobp) nil
            (backward-char 1))
          (setq prev-end (point))
          (beginning-of-sas-statement 1 t))
        (if (or
             (looking-at
              "data[ \n\t;]\\|proc[ \n\t]\\|%?do[ \n\t;]\\|%macro[ \n\t]\\|/\\*")
             (save-excursion
               (re-search-forward
                "\\b%?then\\>[ \n\t]*\\b%?do\\>\\|\\b%?else\\>[ \n\t]*\\b%?do\\>"
                prev-end 1 1))) ; fixed 1/30/95 to avoid being fooled by
				; variable names starting with "do"
            (+ (current-indentation) sas-indent-width)
          (if (looking-at "%?end[ ;\n]\\|%mend[ ;\n]\\|\\*/")
              (max (- (current-indentation) sas-indent-width) 0)
            (current-indentation)))))))

;; added 2/1/95
(defun sas-comment-start-col ()
  "If the current line is inside a /* */ comment, returns column in which the
opening /* appears.  returns 0 otherwise."
  (let ((pos (point)))
    (save-excursion
      (if (and (search-backward "*/" (point-min) 1 1)
               (search-forward "/*" pos 1 1))
          (current-indentation)
        0))))


;;  Created 6/27/94 to verify that RUN; statements match PROC and DATA
;;  statements.  Useful since indentation my be goofy w/o "RUN;"
(defun sas-check-run-statements ()
  "Check to see that \"run\" statements are matched with proc, data statements."
  (interactive)
  (let (pos
	(ok t)
	(eob-ok t))
    (save-excursion
      (beginning-of-line)
      (while ok
        (if (re-search-forward
	     "\\(^[ \t]*run[ ;]\\)\\|\\(^[ \t]*proc \\|^[ \t]*data[ ;]\\)"
	     nil 1)
	    (if (match-beginning 2)
		(if (re-search-forward
		     "\\(^[ \t]*run[ ;]\\)\\|\\(^[ \t]*proc \\|^[ \t]*data[ ;]\\)"
		     nil t)
		    (progn (setq pos (point))
			   (setq ok (match-beginning 1)))
		  (setq eob-ok nil pos (point-max))))
	  (setq ok nil)))
      (setq ok (eobp)))
    (if (and ok eob-ok) (message "Run statements match")
      (goto-char pos)
      (beep)
      (message "Missing Run Statement."))))


(defun sas-fix-life-tables (start end)
  "Remove censored and duplicate observations from life tables generated by
Proc Lifetest.  Operates on current region.  A major space saver if there is
heavy censoring."
  (interactive "r")
  (save-excursion
    (shell-command-on-region
     start end
     "sed \"\\?          *\\.          *\\.          *\\.    ?d\"" t)))
;;(vip-goto-line 1)
;;(setq ex-g-flag nil
;;ex-g-variant nil)
;;(vip-ex "1,$g/           \\.           \\.           \\.    /d")))

(defun sas-fix-page-numbers (offset &optional page-num)
  "Fix number of current page in sas output files after editing.  Add
OFFSET to actual page number."
  (interactive "P")
  (if (not offset) (setq offset 0))
  (if (not page-num) (setq page-num (sas-page-number)))
  (save-excursion
    (if (/= (preceding-char) ?\C-l) (backward-page 1))
    (let (end len mstart mend)
      (save-excursion
        (forward-line sas-page-number-max-line)
        (setq end (point)))
      (if (re-search-forward
           "\\(^[0-9]+[ ]\\)\\|\\([ ][0-9]+$\\)"
           end t)
          (progn (setq len (- (match-end 0) (match-beginning 0))
                       mstart (match-beginning 0)
                       mend (match-end 0))
                 (delete-region mstart mend)
                 (if (eolp)
                 (insert (format
                          (concat "%" len "d") (+ page-num offset)))
                 (insert (substring
                          (concat (+ (sas-page-number) offset) "      ")
                          0 len))))))))

(defun sas-page-fix (start)
  "Fix page numbers in sas output from point to end of file.
If START is given this will be the number for the current page."
  (interactive "P")
  (let (offset (pnum (sas-page-number)))
  (if (not start) (setq offset 0)
    (setq offset (- start pnum)))
  (while (not (eobp))
    (sas-fix-page-numbers offset pnum)
    (setq pnum (1+ pnum))
    (forward-page 1))))

(defun fix-page-breaks ()
  "Fix page breaks in SAS 6 print files."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (if (looking-at "\f") (delete-char 1))
    (replace-regexp "^\\(.+\\)\f" "\\1\n\f\n")
    (goto-char (point-min))
    (replace-regexp "^\f\\(.+\\)" "\f\n\\1")
    (goto-char (point-min))
    (replace-regexp "
$" "")
    (goto-char (point-min))
    (replace-regexp "
\\([^
\\$]+\\)" "\n\\1")
    (goto-char (point-max))
    (if (not (bobp))
        (progn (backward-char 1)
               (if (not (looking-at "\n"))
                   (progn (forward-char 1) (open-line 1)))))))

(defun sas-page-number ()
  ;; like what-page except it returns an integer page number
  "Return page number of point in current buffer."
  (let ((opoint (point))) (save-excursion
       (goto-char (point-min))
       (1+ (sas-how-many page-delimiter opoint)))))

(defun sas-how-many (regexp &optional end)
  ;; a copy of `how-many' which returns an integer
  ;; rather than a message
  "Return number of matches for REGEXP following point."
  (let ((count 0) opoint)
    (save-excursion
     (while (and (not (eobp))
		 (progn (setq opoint (point))
			(re-search-forward regexp end t)))
       (if (= opoint (point))
	   (forward-char 1)
	 (setq count (1+ count))))
     count)))

(defun beginning-of-sas-proc ()
  "Move point to beginning of sas proc, macro or data step."
  (interactive)
  (let ((case-fold-search t))
    (forward-char -1)
    (while (not (or (looking-at "data\\|proc\\|%macro")
                    (bobp)))
      (re-search-backward "proc\\|data\\|%macro" (point-min) 1)
      (beginning-of-sas-statement 1))))

(defun next-sas-proc (arg)
  "Move point to beginning of next sas proc."
  (interactive "P")
  (let ((case-fold-search t))
    (forward-char 1)
    (if (re-search-forward
         "^[ \t]*\\(data[ ;]\\|proc[ ;]\\|endsas[ ;]\\|g?options[ ;]\\|%macro[ ;]\\)"
         nil t arg)
        (beginning-of-sas-statement 1)
      (forward-char -1))))

(defun set-sas-file-name ()
  "Stores the name of the current sas file."
  (let ((name (buffer-file-name)))
    (cond ((not name))
          ((string-match (substring name -4 nil)
			 "\\.sas\\|\\.lst\\|\\.log")

           (setq sas-file-name (substring name 0 (- (length name) 4)))
           (setq sas-buffer-name (buffer-name))
	   (setq sas-file-root (substring sas-buffer-name 0
					  (- (length sas-buffer-name) 4))))
          (t (message "This file does not have a standard suffix")))))

;;  created 6/27/94
(defun sas-set-alternate-file-name (name)
  "Stores the NAME of an alternate sas file.
When this file is submitted with `submit-sas', the alternate file will
be submitted instead.  `sas-submitable' is automatically sets to t."
    (interactive "f")
    (cond ((string-match (substring name -4 nil)
			 "\\.sas\\|\\.lst\\|\\.log")
           (setq sas-file-name (substring name 0 (- (length name) 4)))
           (setq sas-submitable t))
          (t (message "This file does not have a standard suffix"))))

(defun switch-to-sas-source ()
  "Switches to sas source file associated with the current file."
  (interactive)
  (switch-to-sas-file "sas"))

(defun switch-to-sas-lst ()
  "Switches to sas source file associated with the current file."
  (interactive)
  (switch-to-sas-file "lst"))

(defun switch-to-sas-log ()
  "Switches to sas source file associated with the current file."
  (interactive)
  (switch-to-sas-file "log"))

(defun switch-to-sas-source-other-window ()
  "Switches to sas source file associated with the current file."
  (interactive)
  (switch-to-sas-file-other-window "sas"))

(defun switch-to-sas-lst-other-window ()
  "Switches to sas source file associated with the current file."
  (interactive)
  (switch-to-sas-file-other-window "lst"))

(defun switch-to-sas-log-other-window ()
  "Switches to sas source file associated with the current file."
  (interactive)
  (switch-to-sas-file-other-window "log"))

;;(defun switch-to-sas-file (suff &optional revert silent)
;;  "Switches to sas \"SUFF\" file associated with the current file"
;;  (let* ((sfile sas-file-name)
;;	 (buf (get-file-buffer (concat sfile "." suff)))
;;	 (sas-require-confirmation
;;           (and sas-require-confirmation (not revert))))
;;     (if (or sas-require-confirmation (string-equal suff "sas") (not buf))
;;         (find-file (concat sfile "." suff))
;;       (progn (switch-to-buffer buf)
;;              (if (not (verify-visited-file-modtime (current-buffer)))
;;                  (progn (revert-buffer t t)
;;                         (if (not silent)
;;                             (message "File has changed on disk.  Buffer automatically updated."))))))
;;     (setq sas-file-name sfile))
;;   (if (string-equal suff "sas")
;;       (if (not (string-equal major-mode "sas-mode"))
;;           (sas-mode))
;;     (if (not (string-equal major-mode "sasl-mode"))
;;         (sasl-mode))))
;;
;;(defun switch-to-sas-file-other-window (suff)
;;  "Switches to sas \"SUFF\" file associated with the current file"
;;  (let* ((sfile sas-file-name)
;;	 (buf (get-file-buffer (concat sfile "." suff))))
;;    (if (or sas-require-confirmation (string-equal suff "sas") (not buf))
;;	(find-file-other-window (concat sfile "." suff))
;;      (progn (switch-to-buffer-other-window buf)
;;	     (if (not (verify-visited-file-modtime (current-buffer)))
;;		 (progn (revert-buffer t t)
;;			(message "File has changed on disk.  Buffer automatically updated.")))))
;;    (setq sas-file-name sfile))
;;  (if (string-equal suff "sas")
;;      (if (not (string-equal major-mode "sas-mode"))
;;	  ;;(sas-mode)
;;	  )
;;    (if (not (string-equal major-mode "sasl-mode"))
;;	;;(sasl-mode)
;;	)))

(defun switch-to-sas-file (suff)
  "Switches to sas \"SUFF\" file associated with the current file."
  (switch-to-buffer (set-sas-file-buffer suff)))

(defun switch-to-sas-file-other-window (suff)
  "Switches to sas \"SUFF\" file associated with the current file."
  (switch-to-buffer-other-window (set-sas-file-buffer suff)))

;;  The following was created 6/7/94 to handle buffers without messing up
;;  windows.

(defun set-sas-file-buffer (suff &optional revert silent)
  "Sets current buffer to sas \"SUFF\" file associated with the current file."
  (let* ((sfile sas-file-name)
         (buf (get-file-buffer (concat sfile "." suff)))
         (sas-require-confirmation
          (and sas-require-confirmation (not revert))))
    (if (or sas-require-confirmation (string-equal suff "sas") (not buf))
        (set-buffer (find-file-noselect (concat sfile "." suff)))
      (progn (set-buffer buf)
             (if (not (verify-visited-file-modtime (current-buffer)))
                 (progn (revert-buffer t t)
                        (if (not silent)
                            (message "File has changed on disk.  Buffer automatically updated."))))))
    (setq sas-file-name sfile))
  ;;(if (string-equal suff "sas")
  ;; (if (not (string-equal major-mode "sas-mode")) (sas-mode))
  ;; (if (not (string-equal major-mode "sasl-mode"))(sasl-mode))
  (current-buffer))

(defun switch-to-sas-process-buffer ()
  "Switch to sas-process-buffer."
  (interactive)
  (let (buf proc-name)
    (setq proc-name (concat "SAS" sas-file-name)
          buf (concat "*" proc-name "*"))
    (switch-to-buffer-other-window buf)))

(defun submit-sas ()
  ;; 6/17/94  added sas-submitable local variable.
  "Submit SAS file as shell command."
  (interactive)
  (if ;; can file be run, or is it only for inclusion?
      (or sas-submitable
          (progn
            (beep)
            (y-or-n-p
             (format
	      "Submission is disabled for this file.  Submit it anyway? "))))
      (progn
	;; if buffer name has changed, tell user
        (if (or
             (string-equal sas-buffer-name (buffer-name))
             (not
              (y-or-n-p
               (format
		"The name of this buffer has changed.  Submit the new file? "))))
            (setq sas-buffer-name (buffer-name))
          (set-sas-file-name))
        (let ((sas-file sas-file-name)
	      (sas-root sas-file-root)
	      ;;(sas-buf  sas-buffer-name)
	      proc-name
	      buf)

	  ;; Save buffer to SAS the right file :-).
          (if (buffer-modified-p)
              (if (y-or-n-p (format "Buffer %s is modified. Save it? "
                                    (buffer-name)))
                  (save-buffer)))
          (setq proc-name (concat "SAS" sas-file)
		buf (concat "*" proc-name "*"))
          (if (get-buffer buf)
	      (save-window-excursion (switch-to-buffer buf)
                                     (erase-buffer)
				     (setq default-directory
					   (file-name-directory sas-file))))

          (run-hooks 'sas-pre-run-hook)  ;; added 8/24/94
	  (message "----  Submitting SAS job   ----")
	  ;; (switch-to-buffer buf)
	  (make-comint proc-name
		       sas-program     ;added sas-program 4/29/94
		       nil
		       sas-root)
	  (save-window-excursion
	    (switch-to-buffer buf)
	    (setq sas-file-name sas-file)
	    (bury-buffer buf))

          (message "----  SAS job submitted  ----   ")

          (if sas-notify;;  added 4/7/94
              (set-process-sentinel (get-process proc-name) 'sas-sentinel)
            (display-buffer buf t))))
    (message "----  File not submitted  ----")))

;; 5/2/94 Modified sas-sentinel to check for errors in log file upon
;; completion.
(defun sas-sentinel (proc arg);; created 4/7/94
  "Notify user that SAS run is done."
  (beep)
  ;;(if (string-equal arg "finished\n")
  (save-excursion
    (let (msg buf win (sbuf (concat "*" (process-name proc) "*")))
      (setq msg
            (format "SAS %s %s"
                    (substring arg 0 -1)
                    (if sas-error-notify
                        ;;(save-window-excursion
                        (progn
			  (set-buffer sbuf)
			  (setq buf (set-sas-file-buffer "log" t t))
			  (goto-char (point-min))
			  (setq win (get-buffer-window buf))
			  (save-window-excursion
			    (if win
				(progn
				  (select-window win)
				  (if (re-search-forward "^ERROR" nil t)
				      " (See .log file for errors)"
				    ""))
			      (switch-to-buffer buf)
			      (if (re-search-forward "^ERROR" nil t)
				  " (See .log file for errors)"
				""))))
		      "")))
      (set-buffer sbuf)
      (goto-char (point-max))
      (insert msg)
      (bury-buffer (get-buffer sbuf))
      ;;(if (and sas-notify-popup window-system)
      ;;    (x-popup-dialog t
      ;;		(list "SAS Menu" (cons msg  nil) )))
      ;;(if (not (minibuffer-window-active-p)) (princ msg))
      (princ msg))))

;; 5/2/94 Modified run-sas-on-region to separate log and output buffers.
;;
;;(defun run-sas-on-region (start end append &optional buffer)
;;  "Submit region to SAS"
;;  (interactive "r\nP")
;;  (message "----  Running SAS  ----")
;;  (let ((sfile sas-file-name)
;;        (shell-file-name "/bin/sh")
;;        serror buff)
;;    (setq buffer (or buffer "*SAS output*"))
;;    (save-excursion
;;      (shell-command-on-region
;;       start end;; added sas-program
;;       (concat sas-program " -nonews -stdio 2> /tmp/_temp_.log" nil))
;;      (get-buffer-create "*SAS Log*")
;;      (save-window-excursion
;;        (switch-to-buffer "*SAS Log*")
;;        (erase-buffer)
;;        (insert-file-contents "/tmp/_temp_.log")
;;        (delete-file "/tmp/_temp_.log")
;;        (setq serror (re-search-forward "^ERROR" nil t))
;;        (if serror () (bury-buffer)))
;;      (setq buff (get-buffer-create buffer))
;;      (save-window-excursion
;;        (switch-to-buffer buff)
;;        (setq sas-file-name sfile)
;;        (if append
;;            (progn
;;              (end-of-buffer)
;;              (insert "\f\n"))
;;          (erase-buffer))
;;        (if (get-buffer "*Shell Command Output*")
;;            (progn (insert-buffer "*Shell Command Output*")
;;                   (kill-buffer "*Shell Command Output*"))
;;          (insert "SAS completed with no output."))
;;        (if append () (sasl-mode))
;;        (message "----  SAS Complete ----")))
;;    (if (not serror)
;;        (switch-to-buffer-other-window  buff)
;;      (switch-to-buffer-other-window "*SAS Log*")
;;      (goto-char serror)
;;      (beep)
;;      (message "Error found in log file.")
;;      )))

(defun switch-to-dataset-log-buffer ()
  "Switch to log buffer for run-sas-on-region."
  (interactive)
  (switch-to-buffer-other-window "*SAS Log*"))

(defun switch-to-dataset-source-buffer ()
  "Switch to source buffer for run-sas-on-region."
  (interactive)
  (switch-to-buffer-other-window (format " *sas-tmp-%s*" sas-dataset)))

;;(defun sas-get-dataset (filename &optional arg opts-p append buffer vars)
;;  "Run proc contents and proc print on SAS dataset.  Automatically prompts
;;for SAS options to use.  Default options are defined by the variable
;;`sas-get-options'.  Output may be updated from within output buffer with
;;C-cr if dataset changes.  Also, the source code which generates the output
;;may be edited with C-cs.  Typing C-cr within the output buffer reexecutes
;;the (modified) source code."
;;  (interactive "fName of SAS dataset (file name):")
;;  (let ((file (file-name-nondirectory filename))
;;        (dir (file-name-directory filename))
;;        (opts sas-get-options)
;;        (minibuffer-history sas-get-options-history)
;;        buf); fsize)
;;    (setq buffer (or buffer (concat "*" file "*")))
;;    (setq opts (if opts-p opts (read-string "SAS options: " opts)))
;;    (setq sas-get-options-history minibuffer-history)
;;    (cond ((string-match (substring file -6 nil) "\\.ssd01")
;;      (setq file (substring file 0 (- (length file) 6))))
;;    (t (error "This file is not a SAS dataset.")))
;;    (setq buf (format " *sas-tmp-%s*" file))
;;    (get-buffer-create buf)
;;    (save-window-excursion
;;      (switch-to-buffer buf)
;;      (erase-buffer)
;;      (setq default-directory dir)
;;      (if opts
;;          (insert (format "options  %s ;\n" opts)))
;;      (insert (format "title \"Contents of SAS dataset `%s'\" ;\n" file))
;;      (insert (format "libname %s '%s' ;\n" sas-tmp-libname dir))
;;      (if (not (equal arg 1))
;;               (insert (format "proc contents data = %s.%s ;\n" sas-tmp-libname file)))
;;      (if (equal arg 2) ()
;;        (insert (format "proc print data = %s.%s ;\n" sas-tmp-libname file))
;;        (if vars (insert (format "  var %s ;\n" vars))))
;;      (run-sas-on-region (point-min) (point-max) append
;;                         buffer)
;;      (get-buffer buffer)
;;      (if append () (sasd-mode))  ;; added 5/5/94
;;      (setq sas-dataset file))
;;    (if (get-buffer-window buffer t)
;;        (raise-frame (window-frame (get-buffer-window buffer t)))
;;    (display-buffer buffer (not append)))
;;    ))

;;(defun revert-sas-dataset ()
;;  "Revert current sas dataset from disk version"
;;  (interactive)
;;  (let* ((file sas-dataset)
;;        (buf (format " *sas-tmp-%s*" file))
;;        (pos (point)))
;;      (save-window-excursion
;;        (switch-to-buffer buf)
;;        (run-sas-on-region (point-min) (point-max) nil
;;                           (concat "*" file ".ssd01*"))
;;        )
;;      (goto-char pos)  ;; added 6/9/94
;;    (sasd-mode)  ;; added 5/5/94
;;    (setq sas-dataset file)))

(defun sas-insert-local-variables ()  ;; created 6/17/94
  "Add local variables code to end of sas source file."
  (interactive)
  (save-excursion
    (if (re-search-forward "* *Local Variables: *;" nil t)
        ()
      (goto-char (point-max))
      (insert "

**  Local Variables:  ;
**  End:  ;
page ;
"))))



;;-*-emacs-lisp-*-
;;;  file name: sas-data.el
;;;
;;;  Version 1.0
;;;
;;;    sas-data-mode:  manage sas datasets
;;;    Copyright (C) 1994 Tom Cook
;;;
;;;    This program is free software; you can redistribute it and/or modify
;;;    it under the terms of the GNU General Public License as published by
;;;    the Free Software Foundation; either version 2 of the License, or
;;;    (at your option) any later version.
;;;
;;;    This program is distributed in the hope that it will be useful,
;;;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;    GNU General Public License for more details.
;;;
;;;    You should have received a copy of the GNU General Public License
;;;    along with this program; if not, write to the Free Software
;;;    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;;;
;;;  Author:   Tom Cook
;;;            Dept. of Biostatistics
;;;            University of Wisconsin - Madison
;;;            Madison, WI 53706
;;;            cook@biostat.wisc.edu
;;   Created: 8/11/94

;;  variables section
(defvar sas-dir-mode-map nil)
(defvar sas-directory-name nil
  "Name of directory associated with this buffer.")
(make-variable-buffer-local 'sas-directory-name)
(defvar sas-dir-buf-end nil)
(make-variable-buffer-local 'sas-dir-buf-end)
(defvar sas-sorted-by-num nil)
(make-variable-buffer-local 'sas-sorted-by-num)
;; user variables

;; keymaps etc...

(if sas-dir-mode-map ()
   (setq sas-dir-mode-map (make-sparse-keymap))
   ;;(define-key sas-dir-mode-map "c" 'sas-contents)
   (define-key sas-dir-mode-map "p" 'sas-print)
   (define-key sas-dir-mode-map "m" 'sas-mark-item)
   (define-key sas-dir-mode-map "u" 'sas-unmark-item)
   (define-key sas-dir-mode-map " " 'sas-next-line)
   (define-key sas-dir-mode-map "\C-n" 'sas-next-line)
   (define-key sas-dir-mode-map "\C-p" 'sas-prev-line)
   (define-key sas-dir-mode-map "\177" 'sas-prev-line-undo)
   (define-key sas-dir-mode-map "\C-b" 'sas-backward-page-narrow)
   (define-key sas-dir-mode-map "\C-v" 'sas-forward-page-narrow)
   (define-key sas-dir-mode-map "\C-m" 'sas-goto-dataset)
   (define-key sas-dir-mode-map [mouse-2] 'sas-mouse-goto-dataset)
   (define-key sas-dir-mode-map "t" 'sas-dir-goto-page)
   (define-key sas-dir-mode-map "q" 'bury-buffer)
   (define-key sas-dir-mode-map "g" 'sas-revert-library)
   (define-key sas-dir-mode-map "1" 'digit-argument)
   (define-key sas-dir-mode-map "2" 'digit-argument)
   (define-key sas-dir-mode-map "3" 'digit-argument)
   (define-key sas-dir-mode-map "4" 'digit-argument)
   (define-key sas-dir-mode-map "5" 'digit-argument)
   (define-key sas-dir-mode-map "6" 'digit-argument)
   (define-key sas-dir-mode-map "7" 'digit-argument)
   (define-key sas-dir-mode-map "8" 'digit-argument)
   (define-key sas-dir-mode-map "9" 'digit-argument)
   (define-key sas-dir-mode-map [menu-bar sas run]
     '("Submit File " . submit-sas))
   )

;(require 'sas)

(defun sas-dir-mode ()
  "Major mode for managing sas files."
  (interactive)
  (kill-all-local-variables)
  (use-local-map sas-dir-mode-map)
  (setq major-mode 'sas-dir-mode)
  (setq mode-name "SAS")
  (setq sas-directory-name (expand-file-name default-directory))
  (toggle-read-only 1))


;;(defun sas-make-library (directory &optional update)
;;  "Create a buffer with the names of all sas datasets from DIRECTORY."
;;  (interactive "DDirectory Name: ")
;;  (let ((dir (expand-file-name directory)) buf out cont pos)
;;    (setq buf (format " *sas-tmp-%s*" dir))
;;    (setq out (concat "*SAS-dir-" dir))
;;    (setq cont (concat "*SAS-cont-" dir))
;;    (get-buffer-create buf)
;;    (if (get-buffer out)
;;        (if update
;;            (progn
;;              (set-buffer out)
;;              (setq buffer-read-only nil)))
;;      (setq update t))
;;    (pop-to-buffer out)
;;    (setq default-directory dir)
;;    (setq pos (point))
;;    (if update
;;        (progn
;;          (save-window-excursion
;;            (set-buffer buf)
;;            (erase-buffer)
;;            (setq default-directory dir)
;;            (insert "options linesize=70 pagesize=1000 ;\n")
;;            (insert (format "title \"Contents of SAS directory `%s'\" ;\n"
;;                            dir))
;;            (insert (format "libname %s '%s' ;\n" sas-tmp-libname dir))
;;            (insert (format "proc contents data = %s._all_ directory details memtype=data ;\n" sas-tmp-libname))
;;            (run-sas-on-region (point-min) (point-max) nil
;;                               out)
;;            (set-buffer out)
;;            (goto-char (point-min))
;;            (if (= (sas-how-many page-delimiter (point-max)) 0)
;;                (let ((buffer-read-only nil))
;;                  (erase-buffer)
;;                  (insert "There are no SAS datasets in this directory")
;;                  (pop-to-buffer out))
;;              (save-excursion
;;                (set-buffer (get-buffer-create cont))
;;                (setq buffer-read-only t)
;;                (let ((buffer-read-only nil))
;;                  (erase-buffer)
;;                  (insert-buffer out)
;;                  (delete-region (point-min)
;;                                 (or (re-search-forward page-delimiter nil t)
;;                                     (point-min)))
;;                  (sas-page-fix 1)
;;                  (goto-char (point-min))
;;                  (sas-dir-mode)
;;                  (sas-narrow-to-page)))
;;              (if (re-search-forward page-delimiter nil t)
;;                  (delete-region (progn (beginning-of-line) (point))
;;                                 (point-max)))
;;              (sas-insert-set-properties (point-min) (point-max))
;;              )
;;            (switch-to-buffer out t)
;;            (goto-char (point-min))
;;            (sas-dir-mode)
;;            (setq sas-dir-buf-end (point-max)))
;;          (goto-char pos)
;;          (sas-move-to-filename (point-max))))))


(defun sas-move-to-filename (&optional eol)
  (or eol (setq eol (progn (end-of-line) (point))))
  (beginning-of-line)
  (if (re-search-forward "\\(^ *[0-9]+ *<*\\)[^:0-9\n]" eol t)
        (goto-char (match-end 1))))

(defun sas-next-line (arg)
  "Move down one line."
  (interactive "p")
  (forward-line arg)
  (sas-move-to-filename (point-max)))
;;(and (< (point) sas-dir-buf-end)
  ;;(forward-line arg)
  ;;(sas-move-to-filename sas-dir-buf-end)))

(defun sas-prev-line (arg)
  "Move up one line."
  (interactive "p")
  (beginning-of-line)
  (re-search-backward "^ *[0-9]+ *<*[^:0-9\n]" (point-min) t)
  (sas-move-to-filename sas-dir-buf-end))

(defun sas-insert-set-properties (beg end)
  (save-excursion
    (goto-char beg)
    (while (< (point) end)
      (if (sas-move-to-filename)
	  (put-text-property (point)
			     (+ 8 (point))
			     'mouse-face 'highlight))
      (forward-line 1))))

(defun sas-get-filename ()
  "Return name of dataset on current line."
  (interactive)
  (save-excursion
    (if (string-equal "*SAS-dir" (substring (buffer-name) 0 8))
        (sas-move-to-filename)
      (goto-char (point-min))
      (re-search-forward "Data Set Name: [^.]*\\."))
    (expand-file-name
     (downcase (concat sas-directory-name
                       (buffer-substring
                        (point)
                        (save-excursion
                          (skip-chars-forward "A-Z0-9_")
                          (point))) ".ssd01")))))

(defun sas-get-file-number ()
  "Return name of dataset on current line."
  (interactive)
  (if (sas-move-to-filename)
      (progn (forward-word -1)
             (re-search-forward "[0-9]*")
             (string-to-number
              (buffer-substring (match-beginning 0)
				(match-end 0))))))

;;(defun sas-contents ()
;;  "Run proc contents on current file."
;;  (interactive)
;;  (let ((buffer-read-only nil) (sas-get-options "linesize=70"))
;;    (sas-get-dataset (sas-get-filename) 2 t t (buffer-name))
;;    (end-of-buffer)
;;    (backward-page-top-of-window 1)))
;;
;;(defun sas-print ()
;;  "Run proc contents on current file."
;;  (interactive)
;;  (sas-get-dataset (sas-get-filename) 1 nil nil nil
;;                   (sas-create-var-string)))

(defun sas-goto-page (arg)
  "Goto top of page ARG.  If no ARG, then goto top of file."
  (interactive "P")
  (goto-char 1)
  (if arg
      (if (> arg 1)
	  (progn
	    (re-search-forward page-delimiter (point-max) 1 (1- arg)))))
  (skip-chars-forward sas-white-chars); was " \f\n" till 5.1.13
  (recenter 1))

(defun forward-page-top-of-window (arg)
  "Move forward to page boundary and leave first line at top of window.
With arg, repeat, or go back if negative. A page boundary is any line
whose beginning matches the regexp `page-delimiter'."
  (interactive "p")
  (forward-page arg)
  (recenter 0))

(defun backward-page-top-of-window (arg)
  "Move backward to page boundary and leave first line at top of window.
With arg, repeat, or go back if negative. A page boundary is any line
whose beginning matches the regexp `page-delimiter'."
  (interactive "p")
  (forward-page (- arg))
  (recenter 0))

(defun sas-narrow-to-page ()
  (save-excursion
    (let* ((min (point-min))
	   (max (point-max)))
      ;;(omin (point-min))
      ;;(omax (point-max)))
      (if (or (bolp) (beginning-of-line)
	      (looking-at page-delimiter))
          (forward-char 1)
        (forward-page -1))
      (setq min (point))
      (forward-page 1)
      (beginning-of-line)
      (setq max (point))
      (narrow-to-region min max))))

(defun sas-forward-page-narrow (arg)
  "Move forward to page boundary and narrow to page.
With arg, repeat, or go back if negative. A page boundary is any line
whose beginning matches the regexp `page-delimiter'."
  (interactive "p")
  (widen)
  (forward-page arg)
  (sas-narrow-to-page)
  (goto-char (point-min)))

(defun sas-backward-page-narrow (arg)
  "Move backward to page boundary and narrow to page.
With arg, repeat, or go back if negative. A page boundary is any line
whose beginning matches the regexp `page-delimiter'."
  (interactive "p")
  (goto-char (point-min))
  (widen)
  (forward-page (- arg))
  (sas-narrow-to-page))

(defun sas-goto-dataset (&optional page)
  (interactive)
  (and sas-directory-name
       (let ((page (or page (sas-get-file-number))))
	     ;;(dir sas-directory-name))
         (if page
             (progn
               (switch-to-buffer-other-window
                (concat "*SAS-cont-" sas-directory-name))
               (widen)
               (sas-goto-page page)
               (sas-narrow-to-page)
               (goto-char (point-min)))))))

;;(defun sas-mouse-goto-dataset (event)
;;  (interactive "e")
;;  (let (page buf)
;;    (save-window-excursion
;;      (save-excursion
;;        (set-buffer (window-buffer (posn-window (event-end event))))
;;        (save-excursion
;;          (goto-char (posn-point (event-end event)))
;;          (setq page (sas-get-file-number)))
;;        (sas-goto-dataset page)
;;        (setq buf (buffer-name))))
;;    (set-buffer buf)
;;    (goto-char (point-min))
;;    (display-buffer buf)))


(defun sas-dir-goto-page (page)
  (interactive "p")
  (widen)
  (sas-goto-page page)
  (sas-narrow-to-page))

(defun sas-mark-item (&optional next)
  (interactive)
  (sas-move-to-filename)
  (beginning-of-line)
  (let ((buffer-read-only nil))
    (if (re-search-forward "^\\( *[0-9]+ *\\) \\([A-Z][A-Z_0-9]*\\) "
			   (save-excursion (end-of-line) (point)) t)
	(replace-match "\\1<\\2>")))
  (or next (sas-next-line 1)))

(defun sas-unmark-item ()
  (interactive)
  (save-excursion
    (beginning-of-line)
    (let ((buffer-read-only nil))
      (if (re-search-forward "^\\( *[0-9]+ *\\)<\\([A-Z][A-Z_0-9]*\\)>"
                             (save-excursion (end-of-line) (point)) t)
          (replace-match "\\1 \\2 ")))))

(defun sas-prev-line-undo (arg)
  (interactive "p")
  (sas-prev-line arg)
  (sas-unmark-item)
  (sas-move-to-filename))

(defun sas-create-var-string ()
  (and (string-equal "*SAS-cont" (substring (buffer-name) 0 9))
       (let (str)
	 (goto-char (point-min))
	 (while
	     (re-search-forward "^\\( *[0-9]+ *\\)<\\([A-Z][A-Z_0-9]*\\)>"
				nil t)
	   (setq str (concat str " " (buffer-substring (match-beginning 2)
						       (match-end 2)))))
	 str)))

;;(defun sas-revert-library ()
;;  "Update current library."
;;  (interactive)
;;  (if sas-directory-name
;;      (sas-make-library sas-directory-name t)))

(provide 'essl-sas)

 ; Local variables section

;;; This file is automatically placed in Outline minor mode.
;;; The file is structured as follows:
;;; Chapters:     ^L ;
;;; Sections:    ;;*;;
;;; Subsections: ;;;*;;;
;;; Components:  defuns, defvars, defconsts
;;;              Random code beginning with a ;;;;* comment
;;; Local variables:
;;; mode: emacs-lisp
;;; mode: outline-minor
;;; outline-regexp: "\^L\\|\\`;\\|;;\\*\\|;;;\\*\\|(def[cvu]\\|(setq\\|;;;;\\*"
;;; End:

;;; essl-sas.el ends here
