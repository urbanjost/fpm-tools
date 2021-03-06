!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()!
!===================================================================================================================================
program demo_fmt
use M_kracken, only : kracken, lget, sget, iget                  ! add command-line parser module
use M_io,      only : read_line
use M_strings, only : fmt, indent
implicit none
character(len=:),allocatable :: line
character(len=:),allocatable :: bigline
integer                      :: iline
integer                      :: width
integer                      :: step
integer                      :: step_before
character(len=20)            :: style
!-----------------------------------------------------------------------------------------------------------------------------------
   call kracken('fmt','-help .f. -version .f. -w 75 ') ! define command arguments,default values and crack command line
   call help_usage(lget('fmt_help'))                                ! if -help option is present, display help text and exit
   call help_version(lget('fmt_version'))                           ! if -version option is present, display version text and exit
!-----------------------------------------------------------------------------------------------------------------------------------
   width = iget('fmt_w')
!-----------------------------------------------------------------------------------------------------------------------------------
   step=0
   iline=0
   bigline=''
   style='(a)'
   INFINITE: do while (read_line(line)==0)
      iline=iline+1
      step_before=step            ! indent of previous line
      step=indent(line)           ! indent of line just read
      if(iline.eq.1)then
         step_before=step         ! prevent first line from meeting criteria to output a paragraph
         call makeformat()
      endif
      if(line.eq.'')then ! hit blank line so output previous paragraph
         if(bigline.ne.'')then
            write(*,fmt=style) fmt(bigline,width)
         endif
         bigline=''
         style='(a)'
         write(*,*)
      elseif(step.ne.step_before)then ! hit new indent so output previous paragraph
         if(bigline.ne.'')then
            write(*,fmt=style) fmt(bigline,width)
         endif
         bigline=line
         call makeformat()
      else
         bigline=bigline//' '//line
      endif
   enddo INFINITE
   if(bigline.ne.'')then
      write(*,style) fmt(bigline,width)
   endif
!-----------------------------------------------------------------------------------------------------------------------------------
contains
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine makeformat
   if(step.ne.0)then                      ! generate format statement
      write(style,'("(",i0,"x,a)")')step
   else
      style='(a)'
   endif
end subroutine makeformat
subroutine help_version(l_version)
implicit none
! @(#)help_version(3f): prints version information
logical,intent(in)             :: l_version
character(len=:),allocatable   :: help_text(:)
integer                        :: i
if(l_version)then
help_text=[ CHARACTER(LEN=128) :: &
'@(#)PRODUCT:        GPF (General Purpose Fortran) utilities and examples>',&
'@(#)PROGRAM:        _fmt(1)>',&
'@(#)DESCRIPTION:    simple reformatting of paragraphs>',&
'@(#)VERSION:        1.0, 20190421>',&
'@(#)AUTHOR:         John S. Urban>',&
'@(#)REPORTING BUGS: http://www.urbanjost.altervista.org/>',&
'@(#)HOME PAGE:      http://www.urbanjost.altervista.org/index.html>',&
'@(#)LICENSE:        Public Domain. This is free software: you are free to change and redistribute it.>',&
'@(#)                There is NO WARRANTY, to the extent permitted by law.>',&
'@(#)COMPILED:       Mon, Dec 28th, 2020 8:40:00 PM>',&
'']
   WRITE(*,'(a)')(trim(help_text(i)(5:len_trim(help_text(i),kind=kind(1))-1)),i=1,size(help_text))
   stop ! if -version was specified, stop
endif
end subroutine help_version
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine help_usage(l_help)
implicit none
! @(#)help_usage(3f): prints help information
logical,intent(in)             :: l_help
character(len=:),allocatable :: help_text(:)
integer                        :: i
if(l_help)then
help_text=[ CHARACTER(LEN=128) :: &
'NAME                                                                            ',&
'       _fmt(1f) - [FUNIX:FILE EDIT] simple text formatter                       ',&
'       (LICENSE:PD)                                                             ',&
'                                                                                ',&
'SYNOPSIS                                                                        ',&
'       _fmt [OPTION]...                                                         ',&
'                                                                                ',&
'DESCRIPTION                                                                     ',&
'   Reformat each paragraph on standard input, writing to standard output. A     ',&
'   paragraph ends when a blank line is encountered or the left margin           ',&
'   changes.                                                                     ',&
'                                                                                ',&
'OPTIONS                                                                         ',&
'       -w, WIDTH               maximum line width (default of 75 columns)       ',&
'       --help                  display this help and exit                       ',&
'       --version               output version information and exit              ',&
'AUTHOR                                                                          ',&
'   John S. Urban                                                                ',&
'LICENSE                                                                         ',&
'   Public Domain                                                                ',&
'']
   WRITE(*,'(a)')(trim(help_text(i)),i=1,size(help_text))
   stop ! if -help was specified, stop
endif
end subroutine help_usage
!-----------------------------------------------------------------------------------------------------------------------------------
!>
!!##NAME
!!        _fmt(1f) - [FUNIX:FILE EDIT] simple text formatter
!!        (LICENSE:PD)
!!
!!##SYNOPSIS
!!
!!        _fmt [OPTION]...
!!
!!##DESCRIPTION
!!    Reformat each paragraph on standard input, writing to standard output. A
!!    paragraph ends when a blank line is encountered or the left margin
!!    changes.
!!
!!##OPTIONS
!!        -w, WIDTH               maximum line width (default of 75 columns)
!!        --help                  display this help and exit
!!        --version               output version information and exit
!!##AUTHOR
!!    John S. Urban
!!##LICENSE
!!    Public Domain
end program demo_fmt
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
