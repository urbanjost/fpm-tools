!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
Module M_sort
use, intrinsic :: ISO_FORTRAN_ENV, only : INT8, INT16, INT32, INT64       !  1           2           4           8
use, intrinsic :: ISO_FORTRAN_ENV, only : REAL32, REAL64, REAL128         !  4           8          10
implicit none                       ! declare that all variables must be explicitly declared
integer,parameter :: dp=kind(0.0d0)
integer,parameter :: cd=kind(0.0d0)
private                             ! the PRIVATE declaration requires use of a module, and changes the default from PUBLIC
public sort_quick_rx
public sort_shell

public :: swap
!-public :: exchange
public :: swap_any

public unique

public tree_insert
public tree_print
public tree_node

!===================================================================================================================================

! ident_1="@(#)M_sort::sort_shell(3f): Generic subroutine sorts the array X using a shell sort"

! SORT_SHELL is a Generic Interface in a module with PRIVATE specific procedures. This means the individual subroutines
! cannot be called from outside of this module.
interface sort_shell
   module procedure sort_shell_integers, sort_shell_reals, sort_shell_strings
   module procedure sort_shell_complex, sort_shell_doubles, sort_shell_complex_double
end interface
!===================================================================================================================================

! ident_2="@(#)M_sort::unique(3f): assuming an array is sorted, return array with duplicate values removed"

interface unique
   module procedure unique_integers, unique_reals, unique_strings_allocatable_len !!, unique_strings
   module procedure unique_complex, unique_doubles, unique_complex_double
end interface
!===================================================================================================================================

! ident_3="@(#)M_sort::swap(3f): swap two variables of like type (real,integer,complex,character,double)"

interface swap
   module procedure r_swap, i_swap, c_swap, s_swap, d_swap, l_swap, cd_swap
end interface

!-interface exchange
!-   module procedure exchange_scalar, exchange_array
!-end interface

interface swap_any
   module procedure swap_any_scalar, swap_any_array
end interface
!===================================================================================================================================
interface sort_quick_rx
   module procedure sort_quick_rx_real
   module procedure sort_quick_rx_doubleprecision
   module procedure sort_quick_rx_integer
   module procedure sort_quick_rx_character
   module procedure sort_quick_rx_complex
end interface
!===================================================================================================================================
! For TREE SORT
type tree_node
   integer :: value
   type (tree_node), pointer :: left, right
end type tree_node

!use M_anything, only : anything_to_bytes, bytes_to_anything
interface anything_to_bytes
   module procedure anything_to_bytes_arr
   module procedure anything_to_bytes_scalar
end interface anything_to_bytes

!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
contains
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
!>
!!##NAME
!!    M_sort(3fm) - [M_sort] Fortran module containing sorting algorithms for arrays of standard scalar types
!!    (LICENSE:PD)
!!
!!##SYNOPSIS
!!
!!    use M_sort, only : sort_shell, sort_quick_rx, unique
!!
!!##DESCRIPTION
!!    Under development. Currently only provides a few common routines, but it is intended that
!!    other procedures will provide a variety of sort methods, including ...
!!
!!
!!    Exchange sorts      Bubble sort, Cocktail shaker sort, Odd-even sort, Comb sort, Gnome sort, Quicksort, Stooge sort, Bogosort
!!    Selection sorts     Selection sort, Heapsort, Smoothsort, Cartesian tree sort, Tournament sort, Cycle sort
!!    Insertion sorts     Insertion sort, Shellsort, Splaysort, Tree sort, Library sort, Patience sorting
!!    Merge sorts         Merge sort, Cascade merge sort, Oscillating merge sort, Polyphase merge sort
!!    Distribution sorts  American flag sort, Bead sort, Bucket sort, Burstsort, Counting sort, Pigeonhole sort, Proxmap sort,
!!                        Radix sort, Flashsort
!!    Concurrent sorts    Bitonic sorter, Batcher odd-even mergesort, Pairwise sorting network
!!    Hybrid sorts        Block merge sortTimsort, Introsort, Spreadsort
!!    Other               Topological sorting, Pancake sorting, Spaghetti sort
!!
!!    and an overview of topics concerning sorting
!!
!!    Theory              Computational complexity theory, Big O notation, Total orderLists, InplacementStabilityComparison sort,
!!                        Adaptive sort, Sorting network, Integer sorting, X + Y sorting, Transdichotomous model, Quantum sort
!!
!!    In the mean time those keywords can be useful in locating materials on the WWW, especially in Wikipedia.
!!
!!##QUICKSORT
!!
!!    Quicksort, also known as partition-exchange sort, uses these steps
!!
!!     o Choose any element of the array to be the pivot.
!!     o Divide all other elements (except the pivot) into two partitions.
!!     o All elements less than the pivot must be in the first partition.
!!     o All elements greater than the pivot must be in the second partition.
!!     o Use recursion to sort both partitions.
!!     o Join the first sorted partition, the pivot, and the second sorted partition.
!!
!!    The best pivot creates partitions of equal length (or lengths differing
!!    by 1).
!!
!!    The worst pivot creates an empty partition (for example, if the pivot
!!    is the first or last element of a sorted array).
!!
!!    The run-time of Quicksort ranges from O(n log n) with the best
!!    pivots, to O(n2) with the worst pivots, where n is the
!!    number of elements in the array.
!!
!!    Quicksort has a reputation as the fastest sort. Optimized variants of
!!    quicksort are common features of many languages and libraries.
!>
!!##NAME
!!    sort_shell(3f) - [M_sort] Generic subroutine sorts the array X using Shell's method
!!    (LICENSE:PD)
!!##SYNOPSIS
!!
!!    subroutine sort_shell(lines,order[,startcol,endcol])
!!
!!     character(len=*),intent(inout) :: lines(:)
!!     character(len=*),intent(in)    :: order
!!     integer,optional,intent(in)    :: startcol, endcol
!!
!!    subroutine sort_shell(ints,order)
!!
!!     integer,intent(inout)          :: ints(:)
!!     character(len=*),intent(in)    :: order
!!
!!    subroutine sort_shell(reals,order)
!!
!!     real,intent(inout)             :: reals(:)
!!     character(len=*),intent(in)    :: order
!!
!!    subroutine sort_shell(complexs,order,type)
!!
!!     character(len=*),intent(inout) :: lines(:)
!!     character(len=*),intent(in)    :: order
!!     character(len=*),intent(in)    :: type
!!
!!
!!##DESCRIPTION
!!
!!       subroutine sort_shell(3f) sorts an array over a specified field
!!       in numeric or alphanumeric order.
!!
!!       From Wikipedia, the free encyclopedia:
!!
!!       The step-by-step process of replacing pairs of items during the shell
!!       sorting algorithm. Shellsort, also known as Shell sort or Shell's
!!       method, is an in-place comparison sort. It can be seen as either a
!!       generalization of sorting by exchange (bubble sort) or sorting by
!!       insertion (insertion sort).[3] The method starts by sorting pairs of
!!       elements far apart from each other, then progressively reducing the gap
!!       between elements to be compared. Starting with far apart elements, it
!!       can move some out-of-place elements into position faster than a simple
!!       nearest neighbor exchange. Donald Shell published the first version
!!       of this sort in 1959.[4][5] The running time of Shellsort is heavily
!!       dependent on the gap sequence it uses. For many practical variants,
!!       determining their time complexity remains an open problem.
!!
!!       Shellsort is a generalization of insertion sort that allows the
!!       exchange of items that are far apart. The idea is to arrange the list
!!       of elements so that, starting anywhere, considering every hth element
!!       gives a sorted list. Such a list is said to be h-sorted. Equivalently,
!!       it can be thought of as h interleaved lists, each individually sorted.[6]
!!       Beginning with large values of h, this rearrangement allows elements
!!       to move long distances in the original list, reducing large amounts
!!       of disorder quickly, and leaving less work for smaller h-sort steps to
!!       do. If the file is then k-sorted for some smaller integer k, then the
!!       file remains h-sorted. Following this idea for a decreasing sequence of
!!       h values ending in 1 is guaranteed to leave a sorted list in the end.
!!
!!     F90 NOTES:
!!
!!      o  procedure names are declared private in this module so they are not accessible except by their generic name
!!      o  procedures must include a "use M_sort" to access the generic name SORT_SHELL
!!      o  if these routines are recompiled, routines with the use statement should then be recompiled and reloaded.
!!
!!##OPTIONS
!!    Usage:
!!
!!     X          input/output array to sort of type CHARACTER, INTEGER,
!!                REAL, DOUBLEPRECISION, COMPLEX, or DOUBLEPRECISION COMPLEX.
!!     order      sort order
!!                o A for Ascending  (a-z for strings, small to large for values)
!!                o D for Descending (z-a for strings, large to small for values, default)
!!
!!    FOR CHARACTER DATA:
!!
!!     startcol   character position in strings which starts sort field.
!!                Only applies to character values. Defaults to 1. Optional.
!!     endcol     character position in strings which ends sort field
!!                Only applies to character values. Defaults to end of string.
!!                Optional.
!!
!!    FOR COMPLEX AND COMPLEX(KIND=KIND(0.0D0)) DATA:
!!
!!     type       Sort by
!!
!!                  R  for Real component,
!!                  I  for Imaginary component,
!!                  S  Sqrt(R**2+I**2)
!!
!!##EXAMPLE
!!
!!    Sample program
!!
!!       program demo_sort_shell
!!       use M_sort, only : sort_shell
!!       character(len=:),allocatable :: array(:)
!!
!!       array= [ character(len=20) ::                               &
!!       & 'red',    'green', 'blue', 'yellow', 'orange',   'black', &
!!       & 'white',  'brown', 'gray', 'cyan',   'magenta',           &
!!       & 'purple']
!!
!!       write(*,'(a,*(a:,","))')'BEFORE ',(trim(array(i)),i=1,size(array))
!!       call sort_shell(array,order='a')
!!       write(*,'(a,*(a:,","))')'A-Z    ',(trim(array(i)),i=1,size(array))
!!       do i=1,size(array)-1
!!          if(array(i).gt.array(i+1))then
!!             write(*,*)'Error in sorting strings a-z'
!!          endif
!!       enddo
!!
!!       array= [ character(len=20) ::                               &
!!       & 'RED',    'GREEN', 'BLUE', 'YELLOW', 'ORANGE',   'BLACK', &
!!       & 'WHITE',  'BROWN', 'GRAY', 'CYAN',   'MAGENTA',           &
!!       & 'PURPLE']
!!
!!       write(*,'(a,*(a:,","))')'BEFORE ',(trim(array(i)),i=1,size(array))
!!       call sort_shell(array,order='d')
!!       write(*,'(a,*(a:,","))')'Z-A    ',(trim(array(i)),i=1,size(array))
!!       do i=1,size(array)-1
!!          if(array(i).lt.array(i+1))then
!!             write(*,*)'Error in sorting strings z-a'
!!          endif
!!       enddo
!!
!!       end program demo_sort_shell
!!
!!    Expected output
!!
!!       BEFORE red,green,blue,yellow,orange,black,white,brown,gray,cyan,magenta,purple
!!       A-Z    black,blue,brown,cyan,gray,green,magenta,orange,purple,red,white,yellow
!!       BEFORE RED,GREEN,BLUE,YELLOW,ORANGE,BLACK,WHITE,BROWN,GRAY,CYAN,MAGENTA,PURPLE
!!       Z-A    YELLOW,WHITE,RED,PURPLE,ORANGE,MAGENTA,GREEN,GRAY,CYAN,BROWN,BLUE,BLACK
!!
!!##REFERENCE
!!       1.  ALGORITHM 201, SHELLSORT, J. BOOTHROYD, CACM VOL. 6, NO. 8, P 445, (1963)
!!       2.  D. L. SHELL, CACM, VOL. 2, P. 30, (1959)
!!
!!##AUTHOR
!!      John S. Urban, 19970201
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine sort_shell_strings(lines,order,startcol,endcol)

! ident_4="@(#)M_sort::sort_shell_strings(3fp):sort strings over specified field using shell sort"

character(len=*),  intent(inout)          :: lines(:)       ! input/output array
character(len=*),  intent(in)             :: order          ! sort order 'ascending'|'descending'
integer,           optional,intent(in)    :: startcol,  endcol  ! beginning and ending column to sort by
   integer                                :: imax, is, ie

   imax=len(lines(1))                                       ! maximum length of the character variables being sorted
   if(imax.eq.0)return

   if(present(startcol))then                                  ! if the optional parameter is present, use it
     is=min(max(1,startcol),imax)
   else
     is=1
   endif

   if(present(endcol))then                                    ! if the optional parameter is present, use it
     ie=min(max(1,endcol),imax)
   else
     ie=imax
   endif

   if(order(1:1).eq.'a' .or. order(1:1).eq.'A') then
      call sort_shell_strings_lh(lines,is,ie)               ! sort a-z
   else
      call sort_shell_strings_hl(lines,is,ie)               ! sort z-a
   endif
!-----------------------------------------------------------------------------------------------------------------------------------
contains
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_strings_lh(lines,startcol,endcol)

! ident_5="@(#)M_sort::sort_shell_strings_lh(3fp):sort strings(a-z) over specified field using shell sort"

!  1989 John S. Urban
!  lle to sort 'a-z', lge to sort 'z-a'
!  should carefully check for bad input values,
!  return flag indicating whether any strings were equal,
!-----------------------------------------------------------------------------------------------------------------------------------
character(len=*) :: lines(:)
integer,intent(in),optional     :: startcol, endcol
integer                         :: startcol_local, endcol_local
   character(len=:),allocatable :: ihold
   integer           :: n
   integer           :: igap
   integer           :: i,j,k
   integer           :: jg
!-----------------------------------------------------------------------------------------------------------------------------------
   n=size(lines)
   startcol_local=merge(startcol,1,present(startcol))
   endcol_local=merge(endcol,size(lines),present(endcol))
   if(n.gt.0)then
      allocate(character(len=len(lines(1))) :: ihold)
   else
      ihold=''
   endif
   igap=n
!-----------------------------------------------------------------------------------------------------------------------------------
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit INFINITE
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            if(lle(lines(j)(startcol_local:endcol_local),lines(jg)(startcol_local:endcol_local)))exit INSIDE
            ihold=lines(j)
            lines(j)=lines(jg)
            lines(jg)=ihold
            j=j-igap
            if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
         if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_strings_lh
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_strings_hl(lines,startcol,endcol)

! ident_6="@(#)M_sort::sort_shell_strings_hl(3fp):sort strings(z-a) over specified field using shell sort"

!  1989 John S. Urban
!  lle to sort 'a-z', lge to sort 'z-a'
!  should carefully check for bad input values,
!  return flag indicating whether any strings were equal,
!-----------------------------------------------------------------------------------------------------------------------------------
character(len=*) :: lines(:)
integer,intent(in),optional     :: startcol, endcol
integer                         :: startcol_local, endcol_local
   character(len=:),allocatable :: ihold
   integer           :: n
   integer           :: igap
   integer           :: i,j,k
   integer           :: jg
!-----------------------------------------------------------------------------------------------------------------------------------
   n=size(lines)
   startcol_local=merge(startcol,1,present(startcol))
   endcol_local=merge(endcol,size(lines),present(endcol))
   if(n.gt.0)then
      allocate(character(len=len(lines(1))) :: ihold)
   else
      ihold=''
   endif
   igap=n
!-----------------------------------------------------------------------------------------------------------------------------------
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit INFINITE
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            if(lge(lines(j)(startcol_local:endcol_local),lines(jg)(startcol_local:endcol_local)))exit INSIDE
            ihold=lines(j)
            lines(j)=lines(jg)
            lines(jg)=ihold
            j=j-igap
            if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
         if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_strings_hl
!-----------------------------------------------------------------------------------------------------------------------------------
end subroutine sort_shell_strings
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine sort_shell_integers(iarray,order)

! ident_7="@(#)M_sort::sort_shell_integers(3fp):sort integer array using Shell sort and specified order"

integer,intent(inout)          :: iarray(:)   ! iarray input/output array
character(len=*),  intent(in)  ::  order      ! sort order 'ascending'|'descending'

   if(order(1:1).eq.'a' .or. order(1:1).eq.'A') then
      call sort_shell_integers_lh(iarray)
   else
      call sort_shell_integers_hl(iarray)
   endif
!-----------------------------------------------------------------------------------------------------------------------------------
contains
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_integers_hl(iarray)
! Copyright (C) 1989,1996 John S. Urban;  all rights reserved

! ident_8="@(#)M_sort::sort_shell_integers_hl(3fp):sort integer array using Shell sort (high to low)"

integer,intent(inout)      :: iarray(:)  ! input/output array
integer                    :: n          ! number of elements in input array (iarray)
integer                    :: igap, i, j, k, jg
   n=size(iarray)
   igap=n
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit INFINITE
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            if(iarray(j).ge.iarray(jg)) exit INSIDE
            call swap(iarray(j),iarray(jg))
            j=j-igap
            if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
         if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_integers_hl
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_integers_lh(iarray) ! sort an integer array in ascending order (low to high)
! Copyright (C) 1989,1996 John S. Urban;  all rights reserved

! ident_9="@(#)M_sort::sort_shell_integers_lh(3fp):sort integer array using Shell sort low to high"

integer,intent(inout) :: iarray(:)      ! iarray input/output array
   integer            :: n
   integer            :: igap, i, j, k, jg

   n=size(iarray)
   igap=n
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit INFINITE
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            if(iarray(j).le.iarray(jg))exit INSIDE
            call swap(iarray(j),iarray(jg))
            j=j-igap
            if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
         if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_integers_lh
!-----------------------------------------------------------------------------------------------------------------------------------
end subroutine sort_shell_integers
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine sort_shell_reals(array,order)

! ident_10="@(#)M_sort::sort_shell_reals(3fp):sort real array using Shell sort and specified order"

real,intent(inout)          :: array(:)   ! input/output array
character(len=*),intent(in) :: order      ! sort order 'ascending'|'descending'

   if(order(1:1).eq.'a' .or. order(1:1).eq.'A') then
      call sort_shell_reals_lh(array)
   else
      call sort_shell_reals_hl(array)
   endif
!-----------------------------------------------------------------------------------------------------------------------------------
contains
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_reals_hl(array)

! ident_11="@(#)M_sort::sort_shell_reals_hl(3fp):sort real array using Shell sort (high to low)"

!  Copyright(C) 1989 John S. Urban
real,intent(inout) :: array(:) ! input array
   integer         :: n        ! number of elements in input array (array)
   integer         :: i, j, k, igap, jg
   n=size(array)
   igap=n
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit INFINITE
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            if(array(j).ge.array(jg))exit INSIDE
            call swap(array(j),array(jg))
            j=j-igap
            if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
         if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_reals_hl
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_reals_lh(array)

! ident_12="@(#)M_sort::sort_shell_reals_lh(3fp):sort real array using Shell sort (low to high)"

!  Copyright(C) 1989 John S. Urban
real,intent(inout) :: array(:)            ! input array
integer         :: n                   ! number of elements in input array (array)
integer         :: i, j, k, igap, jg
   n=size(array)
   igap=n
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            if(array(j).le.array(jg))exit INSIDE
            call swap(array(j),array(jg))
            j=j-igap
            if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
         if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_reals_lh
!-----------------------------------------------------------------------------------------------------------------------------------
end subroutine sort_shell_reals
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine sort_shell_doubles(array,order)

! ident_13="@(#)M_sort::sort_shell_doubles(3fp):sort double array using Shell sort and specified order"

doubleprecision,intent(inout)          :: array(:)   ! input/output array
character(len=*),intent(in) :: order      ! sort order 'ascending'|'descending'

   if(order(1:1).eq.'a' .or. order(1:1).eq.'A') then
      call sort_shell_doubles_lh(array)
   else
      call sort_shell_doubles_hl(array)
   endif
!-----------------------------------------------------------------------------------------------------------------------------------
contains
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_doubles_hl(array)

! ident_14="@(#)M_sort::sort_shell_doubles_hl(3fp):sort double array using Shell sort (high to low)"

!  Copyright(C) 1989 John S. Urban
doubleprecision,intent(inout) :: array(:) ! input array
integer         :: n        ! number of elements in input array (array)
integer         :: i, j, k, igap, jg
   n=size(array)
   igap=n
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit INFINITE
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            if(array(j).ge.array(jg))exit INSIDE
            call swap(array(j),array(jg))
            j=j-igap
            if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
         if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_doubles_hl
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_doubles_lh(array)

! ident_15="@(#)M_sort::sort_shell_doubles_lh(3fp):sort double array using Shell sort (low to high)"

!  Copyright(C) 1989 John S. Urban
doubleprecision,intent(inout) :: array(:)            ! input array
   integer         :: n                   ! number of elements in input array (array)
   integer         :: i, j, k, igap, jg
   n=size(array)
   igap=n
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            if(array(j).le.array(jg))exit INSIDE
            call swap(array(j),array(jg))
            j=j-igap
            if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
         if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_doubles_lh
!-----------------------------------------------------------------------------------------------------------------------------------
end subroutine sort_shell_doubles
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine sort_shell_complex(array,order,type)  ! select ascending or descending order

! ident_16="@(#)M_sort::sort_shell_complex(3fp):sort complex array using Shell sort"

complex,intent(inout)         :: array(:)   ! array  input/output array
character(len=*),  intent(in) :: order      ! sort order 'ascending'|'descending'
character(len=*),  intent(in) :: type       ! sort by real part, imaginary part, or sqrt(R**2+I**2) ('R','I','S')

if(order(1:1).eq.'a' .or. order(1:1).eq.'A') then
   call sort_shell_complex_lh(array,type)
else
   call sort_shell_complex_hl(array,type)
endif
!-----------------------------------------------------------------------------------------------------------------------------------
contains
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_complex_hl(array,type)

! ident_17="@(#)M_sort::sort_shell_reals_hl(3fp):sort complex array using Shell sort (high to low)"

!     Copyright(C) 1989 John S. Urban   all rights reserved
   complex,intent(inout)       :: array(:)            ! input array
   character(len=*),intent(in) :: type
   integer                     :: n                   ! number of elements in input array (array)
   integer                     :: igap, k, i, j, jg
   doubleprecision             :: csize1, csize2
   n=size(array)
   igap=n
   if(len(type).le.0)return
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit INFINITE
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            select case(type(1:1))
            case('r','R')
               if(real(array(j)).ge.real(array(jg)))exit INSIDE
            case('i','I')
               if(aimag(array(j)).ge.aimag(array(jg)))exit INSIDE
            case default
               csize1=sqrt(dble(array(j))**2+aimag(array(j))**2)
               csize2=sqrt(dble(array(jg))**2+aimag(array(jg))**2)
               if(csize1.ge.csize2)exit INSIDE
            end select
            call swap(array(j),array(jg))
            j=j-igap
         if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
      if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_complex_hl
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_complex_lh(array,type)

! ident_18="@(#)M_sort::sort_shell_reals_lh(3fp):sort complex array using Shell sort (low to high)"

!  Copyright(C) 1989 John S. Urban   all rights reserved
!  array    input array
!  n        number of elements in input array (array)
   complex,intent(inout)         :: array(:)
   character(len=*),  intent(in) :: type       ! sort by real part, imaginary part, or sqrt(R**2+I**2) ('R','I','S')
   integer                       :: n
   integer                       :: igap, k, i, j, jg
   doubleprecision               :: csize1, csize2
   n=size(array)
   igap=n
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit INFINITE
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            select case(type(1:1))
            case('r','R')
               if(real(array(j)).le.real(array(jg)))exit INSIDE
            case('i','I')
               if(aimag(array(j)).le.aimag(array(jg)))exit INSIDE
            case default
               csize1=sqrt(dble(array(j))**2+aimag(array(j))**2)
               csize2=sqrt(dble(array(jg))**2+aimag(array(jg))**2)
               if(csize1.le.csize2)exit INSIDE
            end select
            call swap(array(j),array(jg))
            j=j-igap
         if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
         if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_complex_lh
!-----------------------------------------------------------------------------------------------------------------------------------
end subroutine sort_shell_complex
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine sort_shell_complex_double(array,order,type)  ! select ascending or descending order

! ident_19="@(#)M_sort::sort_shell_complex_double(3fp):sort double complex array using Shell sort"

complex(kind=cd),intent(inout)         :: array(:)   ! array  input/output array
character(len=*),  intent(in) :: order      ! sort order 'ascending'|'descending'
character(len=*),  intent(in) :: type       ! sort by real part, imaginary part, or sqrt(R**2+I**2) ('R','I','S')

if(order(1:1).eq.'a' .or. order(1:1).eq.'A') then
   call sort_shell_complex_double_lh(array,type)
else
   call sort_shell_complex_double_hl(array,type)
endif
!-----------------------------------------------------------------------------------------------------------------------------------
contains
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_complex_double_hl(array,type)

! ident_20="@(#)M_sort::sort_shell_reals_hl(3fp):sort double complex array using Shell sort (high to low)"

!     Copyright(C) 1989 John S. Urban   all rights reserved
   complex(kind=cd),intent(inout)       :: array(:)            ! input array
   character(len=*),intent(in) :: type
   integer                     :: n                   ! number of elements in input array (array)
   integer                     :: igap, k, i, j, jg
   doubleprecision             :: cdsize1, cdsize2
   n=size(array)
   igap=n
   if(len(type).le.0)return
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit INFINITE
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            select case(type(1:1))
            case('r','R')
               if(dble(array(j)).ge.dble(array(jg)))exit INSIDE
            case('i','I')
               if(aimag(array(j)).ge.aimag(array(jg)))exit INSIDE
            case default
               cdsize1=sqrt(dble(array(j))**2+aimag(array(j))**2)
               cdsize2=sqrt(dble(array(jg))**2+aimag(array(jg))**2)
               if(cdsize1.ge.cdsize2)exit INSIDE
            end select
            call swap(array(j),array(jg))
            j=j-igap
         if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
      if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_complex_double_hl
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine sort_shell_complex_double_lh(array,type)

! ident_21="@(#)M_sort::sort_shell_reals_lh(3fp):sort double complex array using Shell sort (low to high)"

!  Copyright(C) 1989 John S. Urban   all rights reserved
!  array    input array
!  n        number of elements in input array (array)
   complex(kind=cd),intent(inout)         :: array(:)
   character(len=*),  intent(in) :: type       ! sort by real part, imaginary part, or sqrt(R**2+I**2) ('R','I','S')
   integer                       :: n
   integer                       :: igap, k, i, j, jg
   doubleprecision               :: cdsize1, cdsize2
   n=size(array)
   igap=n
   INFINITE: do
      igap=igap/2
      if(igap.eq.0) exit INFINITE
      k=n-igap
      i=1
      INNER: do
         j=i
         INSIDE: do
            jg=j+igap
            select case(type(1:1))
            case('r','R')
               if(dble(array(j)).le.dble(array(jg)))exit INSIDE
            case('i','I')
               if(aimag(array(j)).le.aimag(array(jg)))exit INSIDE
            case default
               cdsize1=sqrt(dble(array(j))**2+aimag(array(j))**2)
               cdsize2=sqrt(dble(array(jg))**2+aimag(array(jg))**2)
               if(cdsize1.le.cdsize2)exit INSIDE
            end select
            call swap(array(j),array(jg))
            j=j-igap
         if(j.lt.1) exit INSIDE
         enddo INSIDE
         i=i+1
         if(i.gt.k) exit INNER
      enddo INNER
   enddo INFINITE
end subroutine sort_shell_complex_double_lh
!-----------------------------------------------------------------------------------------------------------------------------------
end subroutine sort_shell_complex_double
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
!>
!!##NAME
!!    sort_quick_rx(3f) - [M_sort] indexed hybrid quicksort of an array
!!    (LICENSE:PD)
!!
!!##SYNOPSIS
!!
!!      subroutine sort_quick_rx(data,index)
!!
!!       ! one of
!!          real,intent(in)            :: data(:)
!!          doubleprecision,intent(in) :: data(:)
!!          integer,intent(in)         :: data(:)
!!          character,intent(in)       :: data(:)
!!          complex,intent(in)         :: data(:)
!!
!!       integer,intent(out)           :: indx(size(data))
!!
!!##DESCRIPTION
!!    A rank hybrid quicksort. The data is not moved. An integer array is
!!    generated instead with values that are indices to the sorted order of
!!    the data. This requires a second array the size of the input array,
!!    which for large arrays could require a significant amount of order. One
!!    major advantage of this method is that any element of a user-defined
!!    that is a scalar intrinsic can be used to provide the sort data and
!!    subsequently the indices can be used to access the entire user-defined
!!    type in sorted order. This makes this seemingly simple sort procedure
!!    usuable with the vast majority of user-defined types.
!!
!!##BACKGROUND
!!    From Leonard J. Moss of SLAC:
!!
!!    Here's a hybrid QuickSort I wrote a number of years ago. It's
!!    based on suggestions in Knuth, Volume 3, and performs much better
!!    than a pure QuickSort on short or partially ordered input arrays.
!!
!!    This routine performs an in-memory sort of the first N elements of
!!    array DATA, returning into array INDEX the indices of elements of
!!    DATA arranged in ascending order. Thus,
!!
!!       DATA(INDX(1)) will be the smallest number in array DATA;
!!       DATA(INDX(N)) will be the largest number in DATA.
!!
!!    The original data is not physically rearranged. The original order
!!    of equal input values is not necessarily preserved.
!!
!!    sort_quick_rx(3f) uses a hybrid QuickSort algorithm, based on several
!!    suggestions in Knuth, Volume 3, Section 5.2.2. In particular, the
!!    "pivot key" [my term] for dividing each subsequence is chosen to be
!!    the median of the first, last, and middle values of the subsequence;
!!    and the QuickSort is cut off when a subsequence has 9 or fewer
!!    elements, and a straight insertion sort of the entire array is done
!!    at the end. The result is comparable to a pure insertion sort for
!!    very short arrays, and very fast for very large arrays (of order 12
!!    micro-sec/element on the 3081K for arrays of 10K elements). It is
!!    also not subject to the poor performance of the pure QuickSort on
!!    partially ordered data.
!!
!!    Complex values are sorted by the magnitude of sqrt(r**2+i**2).
!!
!!    o Created: sortrx(3f): 15 Jul 1986, Len Moss
!!    o saved from url=(0044)http://www.fortran.com/fortran/quick_sort2.f
!!    o changed to update syntax from F77 style; John S. Urban 20161021
!!    o generalized from only real values to include other intrinsic types;
!!      John S. Urban 20210110
!!
!!##EXAMPLE
!!
!!  Sample usage:
!!
!!    program demo_sort_quick_rx
!!    use M_sort, only : sort_quick_rx
!!    implicit none
!!    integer,parameter            :: isz=10000
!!    real                         :: rr(isz)
!!    integer                      :: ii(isz)
!!    integer                      :: i
!!    write(*,*)'initializing array with ',isz,' random numbers'
!!    CALL RANDOM_NUMBER(RR)
!!    rr=rr*450000.0
!!    write(*,*)'sort real array with sort_quick_rx(3f)'
!!    call sort_quick_rx(rr,ii)
!!    write(*,*)'checking index of sort_quick_rx(3f)'
!!    do i=1,isz-1
!!       if(rr(ii(i)).gt.rr(ii(i+1)))then
!!          write(*,*)'Error in sorting reals small to large ',i,rr(ii(i)),rr(ii(i+1))
!!       endif
!!    enddo
!!    write(*,*)'test of sort_quick_rx(3f) complete'
!!    ! use the index array to actually move the input array into a sorted order
!!    rr=rr(ii)
!!    do i=1,isz-1
!!       if(rr(i).gt.rr(i+1))then
!!          write(*,*)'Error in sorting reals small to large ',i,rr(i),rr(i+1)
!!       endif
!!    enddo
!!    write(*,*)'test of sort_quick_rx(3f) complete'
!!    end program demo_sort_quick_rx
!!
!!   Results:
!!
!!     initializing array with        10000  random numbers
!!     sort real array with sort_quick_rx(3f)
!!     checking index of sort_quick_rx(3f)
!!     test of sort_quick_rx(3f) complete
!!     test of sort_quick_rx(3f) complete
!==================================================================================================================================!
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()!
!==================================================================================================================================!
subroutine sort_quick_rx_character(data,indx)

! ident_22="@(#)M_sort::sort_quick_rx_character(3f): indexed hybrid quicksort of a real array"

character(len=*),intent(in)  :: data(:)
integer,intent(out)          :: indx(:)

integer                      :: n
integer                      :: lstk(31),rstk(31),istk
integer                      :: l,r,i,j,p,indexp,indext
character(len=len(data))     :: datap

!  QuickSort Cutoff
!
!  Quit QuickSort-ing when a subsequence contains M or fewer elements and finish off at end with straight insertion sort.
!  According to Knuth, V.3, the optimum value of M is around 9.

integer,parameter :: M=9
!===================================================================================================================================
n=size(data)
if(size(indx).lt.n)then  ! if index is not big enough, only sort part of the data
  write(*,*)'*sort_quick_rx_character* ERROR: insufficient space to store index data'
  n=size(indx)
endif
!===================================================================================================================================
!  Make initial guess for INDEX

do i=1,n
   indx(i)=i
enddo

!  If array is short go directly to the straight insertion sort, else execute a QuickSort
if (N.gt.M)then
   !=============================================================================================================================
   !  QuickSort
   !
   !  The "Qn:"s correspond roughly to steps in Algorithm Q, Knuth, V.3, PP.116-117, modified to select the median
   !  of the first, last, and middle elements as the "pivot key" (in Knuth's notation, "K").  Also modified to leave
   !  data in place and produce an INDEX array.  To simplify comments, let DATA[I]=DATA(INDX(I)).

   ! Q1: Initialize
   istk=0
   l=1
   r=n
   !=============================================================================================================================
   TOP: do

      ! Q2: Sort the subsequence DATA[L]..DATA[R].
      !
      !  At this point, DATA[l] <= DATA[m] <= DATA[r] for all l < L, r > R, and L <= m <= R.
      !  (First time through, there is no DATA for l < L or r > R.)

      i=l
      j=r

      ! Q2.5: Select pivot key
      !
      !  Let the pivot, P, be the midpoint of this subsequence, P=(L+R)/2; then rearrange INDX(L), INDX(P), and INDX(R)
      !  so the corresponding DATA values are in increasing order.  The pivot key, DATAP, is then DATA[P].

      p=(l+r)/2
      indexp=indx(p)
      datap=data(indexp)

      if (data(indx(l)) .gt. datap) then
         indx(p)=indx(l)
         indx(l)=indexp
         indexp=indx(p)
         datap=data(indexp)
      endif

      if (datap .gt. data(indx(r))) then

         if (data(indx(l)) .gt. data(indx(r))) then
            indx(p)=indx(l)
            indx(l)=indx(r)
         else
            indx(p)=indx(r)
         endif

         indx(r)=indexp
         indexp=indx(p)
         datap=data(indexp)
      endif

      !  Now we swap values between the right and left sides and/or move DATAP until all smaller values are on the left and all
      !  larger values are on the right.  Neither the left or right side will be internally ordered yet; however, DATAP will be
      !  in its final position.
      Q3: do
         ! Q3: Search for datum on left >= DATAP
         !   At this point, DATA[L] <= DATAP.  We can therefore start scanning up from L, looking for a value >= DATAP
         !   (this scan is guaranteed to terminate since we initially placed DATAP near the middle of the subsequence).
         I=I+1
         if (data(indx(i)).lt.datap)then
            cycle Q3
         endif
         !-----------------------------------------------------------------------------------------------------------------------
         ! Q4: Search for datum on right <= DATAP
         !
         !   At this point, DATA[R] >= DATAP.  We can therefore start scanning down from R, looking for a value <= DATAP
         !   (this scan is guaranteed to terminate since we initially placed DATAP near the middle of the subsequence).
         Q4: do
            j=j-1
            if (data(indx(j)).le.datap) then
               exit Q4
            endif
         enddo Q4
         !-----------------------------------------------------------------------------------------------------------------------
         ! Q5: Have the two scans collided?
         if (i.lt.j) then
            ! Q6: No, interchange DATA[I] <--> DATA[J] and continue
            indext=indx(i)
            indx(i)=indx(j)
            indx(j)=indext
            cycle Q3
         else
            ! Q7: Yes, select next subsequence to sort
            !   At this point, I >= J and DATA[l] <= DATA[I] == DATAP <= DATA[r], for all L <= l < I and J < r <= R.
         !   If both subsequences are more than M elements long, push the longer one on the stack
            !   and go back to QuickSort the shorter; if only one is more than M elements long, go back and QuickSort it;
         !   otherwise, pop a subsequence off the stack and QuickSort it.
            if (r-j .ge. i-l .and. i-l .gt. m) then
               istk=istk+1
               lstk(istk)=j+1
               rstk(istk)=r
               r=i-1
            else if (i-l .gt. r-j .and. r-j .gt. m) then
               istk=istk+1
               lstk(istk)=l
               rstk(istk)=i-1
               l=j+1
            else if (r-j .gt. m) then
               l=j+1
            else if (i-l .gt. m) then
               r=i-1
            else
               ! Q8: Pop the stack, or terminate QuickSort if empty
               if (istk.lt.1) then
                  exit TOP
               endif
               l=lstk(istk)
               r=rstk(istk)
               istk=istk-1
            endif
            cycle TOP
         endif
         ! never get here, as cycle Q3 or cycle TOP
      enddo Q3
      exit TOP
   enddo TOP
endif
!===================================================================================================================================
! Q9: Straight Insertion sort
do i=2,n
   if (data(indx(i-1)) .gt. data(indx(i))) then
      indexp=indx(i)
      datap=data(indexp)
      p=i-1
      INNER: do
         indx(p+1) = indx(p)
         p=p-1
         if (p.le.0)then
            exit INNER
         endif
         if (data(indx(p)).le.datap)then
            exit INNER
         endif
      enddo INNER
      indx(p+1) = indexp
   endif
enddo
!===================================================================================================================================
!     All done
end subroutine sort_quick_rx_character
!==================================================================================================================================!
subroutine sort_quick_rx_integer(data,indx)

! ident_23="@(#)M_sort::sort_quick_rx_integer(3f): indexed hybrid quicksort of a real array"

integer,intent(in)         :: data(:)
integer,intent(out)     :: indx(:)

integer  :: n
integer  :: lstk(31),rstk(31),istk
integer  :: l,r,i,j,p,indexp,indext
integer  :: datap

!  QuickSort Cutoff
!
!  Quit QuickSort-ing when a subsequence contains M or fewer elements and finish off at end with straight insertion sort.
!  According to Knuth, V.3, the optimum value of M is around 9.

integer,parameter :: M=9
!===================================================================================================================================
n=size(data)
if(size(indx).lt.n)then  ! if index is not big enough, only sort part of the data
  write(*,*)'*sort_quick_rx_integer* ERROR: insufficient space to store index data'
  n=size(indx)
endif
!===================================================================================================================================
!  Make initial guess for INDEX

do i=1,n
   indx(i)=i
enddo

!  If array is short go directly to the straight insertion sort, else execute a QuickSort
if (N.gt.M)then
   !=============================================================================================================================
   !  QuickSort
   !
   !  The "Qn:"s correspond roughly to steps in Algorithm Q, Knuth, V.3, PP.116-117, modified to select the median
   !  of the first, last, and middle elements as the "pivot key" (in Knuth's notation, "K").  Also modified to leave
   !  data in place and produce an INDEX array.  To simplify comments, let DATA[I]=DATA(INDX(I)).

   ! Q1: Initialize
   istk=0
   l=1
   r=n
   !=============================================================================================================================
   TOP: do

      ! Q2: Sort the subsequence DATA[L]..DATA[R].
      !
      !  At this point, DATA[l] <= DATA[m] <= DATA[r] for all l < L, r > R, and L <= m <= R.
      !  (First time through, there is no DATA for l < L or r > R.)

      i=l
      j=r

      ! Q2.5: Select pivot key
      !
      !  Let the pivot, P, be the midpoint of this subsequence, P=(L+R)/2; then rearrange INDX(L), INDX(P), and INDX(R)
      !  so the corresponding DATA values are in increasing order.  The pivot key, DATAP, is then DATA[P].

      p=(l+r)/2
      indexp=indx(p)
      datap=data(indexp)

      if (data(indx(l)) .gt. datap) then
         indx(p)=indx(l)
         indx(l)=indexp
         indexp=indx(p)
         datap=data(indexp)
      endif

      if (datap .gt. data(indx(r))) then

         if (data(indx(l)) .gt. data(indx(r))) then
            indx(p)=indx(l)
            indx(l)=indx(r)
         else
            indx(p)=indx(r)
         endif

         indx(r)=indexp
         indexp=indx(p)
         datap=data(indexp)
      endif

      !  Now we swap values between the right and left sides and/or move DATAP until all smaller values are on the left and all
      !  larger values are on the right.  Neither the left or right side will be internally ordered yet; however, DATAP will be
      !  in its final position.
      Q3: do
         ! Q3: Search for datum on left >= DATAP
         !   At this point, DATA[L] <= DATAP.  We can therefore start scanning up from L, looking for a value >= DATAP
         !   (this scan is guaranteed to terminate since we initially placed DATAP near the middle of the subsequence).
         I=I+1
         if (data(indx(i)).lt.datap)then
            cycle Q3
         endif
         !-----------------------------------------------------------------------------------------------------------------------
         ! Q4: Search for datum on right <= DATAP
         !
         !   At this point, DATA[R] >= DATAP.  We can therefore start scanning down from R, looking for a value <= DATAP
         !   (this scan is guaranteed to terminate since we initially placed DATAP near the middle of the subsequence).
         Q4: do
            j=j-1
            if (data(indx(j)).le.datap) then
               exit Q4
            endif
         enddo Q4
         !-----------------------------------------------------------------------------------------------------------------------
         ! Q5: Have the two scans collided?
         if (i.lt.j) then
            ! Q6: No, interchange DATA[I] <--> DATA[J] and continue
            indext=indx(i)
            indx(i)=indx(j)
            indx(j)=indext
            cycle Q3
         else
            ! Q7: Yes, select next subsequence to sort
            !   At this point, I >= J and DATA[l] <= DATA[I] == DATAP <= DATA[r], for all L <= l < I and J < r <= R.
         !   If both subsequences are more than M elements long, push the longer one on the stack
            !   and go back to QuickSort the shorter; if only one is more than M elements long, go back and QuickSort it;
         !   otherwise, pop a subsequence off the stack and QuickSort it.
            if (r-j .ge. i-l .and. i-l .gt. m) then
               istk=istk+1
               lstk(istk)=j+1
               rstk(istk)=r
               r=i-1
            else if (i-l .gt. r-j .and. r-j .gt. m) then
               istk=istk+1
               lstk(istk)=l
               rstk(istk)=i-1
               l=j+1
            else if (r-j .gt. m) then
               l=j+1
            else if (i-l .gt. m) then
               r=i-1
            else
               ! Q8: Pop the stack, or terminate QuickSort if empty
               if (istk.lt.1) then
                  exit TOP
               endif
               l=lstk(istk)
               r=rstk(istk)
               istk=istk-1
            endif
            cycle TOP
         endif
         ! never get here, as cycle Q3 or cycle TOP
      enddo Q3
      exit TOP
   enddo TOP
endif
!===================================================================================================================================
! Q9: Straight Insertion sort
do i=2,n
   if (data(indx(i-1)) .gt. data(indx(i))) then
      indexp=indx(i)
      datap=data(indexp)
      p=i-1
      INNER: do
         indx(p+1) = indx(p)
         p=p-1
         if (p.le.0)then
            exit INNER
         endif
         if (data(indx(p)).le.datap)then
            exit INNER
         endif
      enddo INNER
      indx(p+1) = indexp
   endif
enddo
!===================================================================================================================================
!     All done
end subroutine sort_quick_rx_integer
!==================================================================================================================================!
subroutine sort_quick_rx_complex(data,indx)

! ident_24="@(#)M_sort::sort_quick_rx_complex(3f): indexed hybrid quicksort of a real array"

complex,intent(in)   :: data(:)
integer,intent(out)  :: indx(:)

integer              :: n
integer              :: lstk(31),rstk(31),istk
integer              :: l,r,i,j,p,indexp,indext
complex              :: datap
doubleprecision      :: cdsize1, cdsize2

!  QuickSort Cutoff
!
!  Quit QuickSort-ing when a subsequence contains M or fewer elements and finish off at end with straight insertion sort.
!  According to Knuth, V.3, the optimum value of M is around 9.

integer,parameter :: M=9
!===================================================================================================================================
n=size(data)
if(size(indx).lt.n)then  ! if index is not big enough, only sort part of the data
  write(*,*)'*sort_quick_rx_complex* ERROR: insufficient space to store index data'
  n=size(indx)
endif
!===================================================================================================================================
!  Make initial guess for INDEX

do i=1,n
   indx(i)=i
enddo

!  If array is short go directly to the straight insertion sort, else execute a QuickSort
if (N.gt.M)then
   !=============================================================================================================================
   !  QuickSort
   !
   !  The "Qn:"s correspond roughly to steps in Algorithm Q, Knuth, V.3, PP.116-117, modified to select the median
   !  of the first, last, and middle elements as the "pivot key" (in Knuth's notation, "K").  Also modified to leave
   !  data in place and produce an INDEX array.  To simplify comments, let DATA[I]=DATA(INDX(I)).

   ! Q1: Initialize
   istk=0
   l=1
   r=n
   !=============================================================================================================================
   TOP: do

      ! Q2: Sort the subsequence DATA[L]..DATA[R].
      !
      !  At this point, DATA[l] <= DATA[m] <= DATA[r] for all l < L, r > R, and L <= m <= R.
      !  (First time through, there is no DATA for l < L or r > R.)

      i=l
      j=r

      ! Q2.5: Select pivot key
      !
      !  Let the pivot, P, be the midpoint of this subsequence, P=(L+R)/2; then rearrange INDX(L), INDX(P), and INDX(R)
      !  so the corresponding DATA values are in increasing order.  The pivot key, DATAP, is then DATA[P].

      p=(l+r)/2
      indexp=indx(p)
      datap=data(indexp)

      cdsize1=sqrt(dble(data(indx(l)))**2+aimag(data(indx(l)))**2)
      cdsize2=sqrt(dble(datap**2+aimag(datap)**2))
      if (cdsize1 .gt. cdsize2) then
         indx(p)=indx(l)
         indx(l)=indexp
         indexp=indx(p)
         datap=data(indexp)
      endif

      cdsize1=sqrt(dble(data(indx(r)))**2+aimag(data(indx(r)))**2)
      cdsize2=sqrt(dble(datap**2+aimag(datap)**2))
      if (cdsize2 .gt. cdsize1) then

      cdsize1=sqrt(dble(data(indx(l)))**2+aimag(data(indx(l)))**2)
      cdsize2=sqrt(dble(data(indx(r)))**2+aimag(data(indx(r)))**2)
         if (cdsize1 .gt. cdsize2) then
            indx(p)=indx(l)
            indx(l)=indx(r)
         else
            indx(p)=indx(r)
         endif

         indx(r)=indexp
         indexp=indx(p)
         datap=data(indexp)
      endif

      !  Now we swap values between the right and left sides and/or move DATAP until all smaller values are on the left and all
      !  larger values are on the right.  Neither the left or right side will be internally ordered yet; however, DATAP will be
      !  in its final position.
      Q3: do
         ! Q3: Search for datum on left >= DATAP
         !   At this point, DATA[L] <= DATAP.  We can therefore start scanning up from L, looking for a value >= DATAP
         !   (this scan is guaranteed to terminate since we initially placed DATAP near the middle of the subsequence).
         I=I+1
         cdsize1=sqrt(dble(data(indx(i)))**2+aimag(data(indx(i)))**2)
         cdsize2=sqrt(dble(datap**2+aimag(datap)**2))
         if (cdsize1.lt.cdsize2)then
            cycle Q3
         endif
         !-----------------------------------------------------------------------------------------------------------------------
         ! Q4: Search for datum on right <= DATAP
         !
         !   At this point, DATA[R] >= DATAP.  We can therefore start scanning down from R, looking for a value <= DATAP
         !   (this scan is guaranteed to terminate since we initially placed DATAP near the middle of the subsequence).
         Q4: do
            j=j-1
            cdsize1=sqrt(dble(data(indx(j)))**2+aimag(data(indx(j)))**2)
            cdsize2=sqrt(dble(datap**2+aimag(datap)**2))
            if (cdsize1.le.cdsize2) then
               exit Q4
            endif
         enddo Q4
         !-----------------------------------------------------------------------------------------------------------------------
         ! Q5: Have the two scans collided?
         if (i.lt.j) then
            ! Q6: No, interchange DATA[I] <--> DATA[J] and continue
            indext=indx(i)
            indx(i)=indx(j)
            indx(j)=indext
            cycle Q3
         else
            ! Q7: Yes, select next subsequence to sort
            !   At this point, I >= J and DATA[l] <= DATA[I] == DATAP <= DATA[r], for all L <= l < I and J < r <= R.
         !   If both subsequences are more than M elements long, push the longer one on the stack
            !   and go back to QuickSort the shorter; if only one is more than M elements long, go back and QuickSort it;
         !   otherwise, pop a subsequence off the stack and QuickSort it.
            if (r-j .ge. i-l .and. i-l .gt. m) then
               istk=istk+1
               lstk(istk)=j+1
               rstk(istk)=r
               r=i-1
            else if (i-l .gt. r-j .and. r-j .gt. m) then
               istk=istk+1
               lstk(istk)=l
               rstk(istk)=i-1
               l=j+1
            else if (r-j .gt. m) then
               l=j+1
            else if (i-l .gt. m) then
               r=i-1
            else
               ! Q8: Pop the stack, or terminate QuickSort if empty
               if (istk.lt.1) then
                  exit TOP
               endif
               l=lstk(istk)
               r=rstk(istk)
               istk=istk-1
            endif
            cycle TOP
         endif
         ! never get here, as cycle Q3 or cycle TOP
      enddo Q3
      exit TOP
   enddo TOP
endif
!===================================================================================================================================
! Q9: Straight Insertion sort
do i=2,n
   cdsize1=sqrt(dble(data(indx(i-1)))**2+aimag(data(indx(i-1)))**2)
   cdsize2=sqrt(dble(data(indx(i)))**2+aimag(data(indx(i)))**2)
   if (cdsize1 .gt. cdsize2) then
      indexp=indx(i)
      datap=data(indexp)
      p=i-1
      INNER: do
         indx(p+1) = indx(p)
         p=p-1
         if (p.le.0)then
            exit INNER
         endif
         cdsize1=sqrt(dble(data(indx(p)))**2+aimag(data(indx(p)))**2)
         cdsize2=sqrt(dble(datap**2+aimag(datap)**2))
         if (cdsize1.le.cdsize2)then
            exit INNER
         endif
      enddo INNER
      indx(p+1) = indexp
   endif
enddo
!===================================================================================================================================
!     All done
end subroutine sort_quick_rx_complex
!==================================================================================================================================!
subroutine sort_quick_rx_doubleprecision(data,indx)

! ident_25="@(#)M_sort::sort_quick_rx_doubleprecision(3f): indexed hybrid quicksort of a real array"

doubleprecision,intent(in) :: data(:)
integer,intent(out)        :: indx(:)

integer                    :: n
integer                    :: lstk(31),rstk(31),istk
integer                    :: l,r,i,j,p,indexp,indext
doubleprecision            :: datap

!  QuickSort Cutoff
!
!  Quit QuickSort-ing when a subsequence contains M or fewer elements and finish off at end with straight insertion sort.
!  According to Knuth, V.3, the optimum value of M is around 9.

integer,parameter :: M=9
!===================================================================================================================================
n=size(data)
if(size(indx).lt.n)then  ! if index is not big enough, only sort part of the data
  write(*,*)'*sort_quick_rx_doubleprecision* ERROR: insufficient space to store index data'
  n=size(indx)
endif
!===================================================================================================================================
!  Make initial guess for INDEX

do i=1,n
   indx(i)=i
enddo

!  If array is short go directly to the straight insertion sort, else execute a QuickSort
if (N.gt.M)then
   !=============================================================================================================================
   !  QuickSort
   !
   !  The "Qn:"s correspond roughly to steps in Algorithm Q, Knuth, V.3, PP.116-117, modified to select the median
   !  of the first, last, and middle elements as the "pivot key" (in Knuth's notation, "K").  Also modified to leave
   !  data in place and produce an INDEX array.  To simplify comments, let DATA[I]=DATA(INDX(I)).

   ! Q1: Initialize
   istk=0
   l=1
   r=n
   !=============================================================================================================================
   TOP: do

      ! Q2: Sort the subsequence DATA[L]..DATA[R].
      !
      !  At this point, DATA[l] <= DATA[m] <= DATA[r] for all l < L, r > R, and L <= m <= R.
      !  (First time through, there is no DATA for l < L or r > R.)

      i=l
      j=r

      ! Q2.5: Select pivot key
      !
      !  Let the pivot, P, be the midpoint of this subsequence, P=(L+R)/2; then rearrange INDX(L), INDX(P), and INDX(R)
      !  so the corresponding DATA values are in increasing order.  The pivot key, DATAP, is then DATA[P].

      p=(l+r)/2
      indexp=indx(p)
      datap=data(indexp)

      if (data(indx(l)) .gt. datap) then
         indx(p)=indx(l)
         indx(l)=indexp
         indexp=indx(p)
         datap=data(indexp)
      endif

      if (datap .gt. data(indx(r))) then

         if (data(indx(l)) .gt. data(indx(r))) then
            indx(p)=indx(l)
            indx(l)=indx(r)
         else
            indx(p)=indx(r)
         endif

         indx(r)=indexp
         indexp=indx(p)
         datap=data(indexp)
      endif

      !  Now we swap values between the right and left sides and/or move DATAP until all smaller values are on the left and all
      !  larger values are on the right.  Neither the left or right side will be internally ordered yet; however, DATAP will be
      !  in its final position.
      Q3: do
         ! Q3: Search for datum on left >= DATAP
         !   At this point, DATA[L] <= DATAP.  We can therefore start scanning up from L, looking for a value >= DATAP
         !   (this scan is guaranteed to terminate since we initially placed DATAP near the middle of the subsequence).
         I=I+1
         if (data(indx(i)).lt.datap)then
            cycle Q3
         endif
         !-----------------------------------------------------------------------------------------------------------------------
         ! Q4: Search for datum on right <= DATAP
         !
         !   At this point, DATA[R] >= DATAP.  We can therefore start scanning down from R, looking for a value <= DATAP
         !   (this scan is guaranteed to terminate since we initially placed DATAP near the middle of the subsequence).
         Q4: do
            j=j-1
            if (data(indx(j)).le.datap) then
               exit Q4
            endif
         enddo Q4
         !-----------------------------------------------------------------------------------------------------------------------
         ! Q5: Have the two scans collided?
         if (i.lt.j) then
            ! Q6: No, interchange DATA[I] <--> DATA[J] and continue
            indext=indx(i)
            indx(i)=indx(j)
            indx(j)=indext
            cycle Q3
         else
            ! Q7: Yes, select next subsequence to sort
            !   At this point, I >= J and DATA[l] <= DATA[I] == DATAP <= DATA[r], for all L <= l < I and J < r <= R.
         !   If both subsequences are more than M elements long, push the longer one on the stack
            !   and go back to QuickSort the shorter; if only one is more than M elements long, go back and QuickSort it;
         !   otherwise, pop a subsequence off the stack and QuickSort it.
            if (r-j .ge. i-l .and. i-l .gt. m) then
               istk=istk+1
               lstk(istk)=j+1
               rstk(istk)=r
               r=i-1
            else if (i-l .gt. r-j .and. r-j .gt. m) then
               istk=istk+1
               lstk(istk)=l
               rstk(istk)=i-1
               l=j+1
            else if (r-j .gt. m) then
               l=j+1
            else if (i-l .gt. m) then
               r=i-1
            else
               ! Q8: Pop the stack, or terminate QuickSort if empty
               if (istk.lt.1) then
                  exit TOP
               endif
               l=lstk(istk)
               r=rstk(istk)
               istk=istk-1
            endif
            cycle TOP
         endif
         ! never get here, as cycle Q3 or cycle TOP
      enddo Q3
      exit TOP
   enddo TOP
endif
!===================================================================================================================================
! Q9: Straight Insertion sort
do i=2,n
   if (data(indx(i-1)) .gt. data(indx(i))) then
      indexp=indx(i)
      datap=data(indexp)
      p=i-1
      INNER: do
         indx(p+1) = indx(p)
         p=p-1
         if (p.le.0)then
            exit INNER
         endif
         if (data(indx(p)).le.datap)then
            exit INNER
         endif
      enddo INNER
      indx(p+1) = indexp
   endif
enddo
!===================================================================================================================================
!     All done
end subroutine sort_quick_rx_doubleprecision
!==================================================================================================================================!
subroutine sort_quick_rx_real(data,indx)

! ident_26="@(#)M_sort::sort_quick_rx_real(3f): indexed hybrid quicksort of a real array"

real,intent(in)         :: data(:)
integer,intent(out)     :: indx(:)

integer  :: n
integer  :: lstk(31),rstk(31),istk
integer  :: l,r,i,j,p,indexp,indext
real     :: datap

!  QuickSort Cutoff
!
!  Quit QuickSort-ing when a subsequence contains M or fewer elements and finish off at end with straight insertion sort.
!  According to Knuth, V.3, the optimum value of M is around 9.

integer,parameter :: M=9
!===================================================================================================================================
n=size(data)
if(size(indx).lt.n)then  ! if index is not big enough, only sort part of the data
  write(*,*)'*sort_quick_rx_real* ERROR: insufficient space to store index data'
  n=size(indx)
endif
!===================================================================================================================================
!  Make initial guess for INDEX

do i=1,n
   indx(i)=i
enddo

!  If array is short go directly to the straight insertion sort, else execute a QuickSort
if (N.gt.M)then
   !=============================================================================================================================
   !  QuickSort
   !
   !  The "Qn:"s correspond roughly to steps in Algorithm Q, Knuth, V.3, PP.116-117, modified to select the median
   !  of the first, last, and middle elements as the "pivot key" (in Knuth's notation, "K").  Also modified to leave
   !  data in place and produce an INDEX array.  To simplify comments, let DATA[I]=DATA(INDX(I)).

   ! Q1: Initialize
   istk=0
   l=1
   r=n
   !=============================================================================================================================
   TOP: do

      ! Q2: Sort the subsequence DATA[L]..DATA[R].
      !
      !  At this point, DATA[l] <= DATA[m] <= DATA[r] for all l < L, r > R, and L <= m <= R.
      !  (First time through, there is no DATA for l < L or r > R.)

      i=l
      j=r

      ! Q2.5: Select pivot key
      !
      !  Let the pivot, P, be the midpoint of this subsequence, P=(L+R)/2; then rearrange INDX(L), INDX(P), and INDX(R)
      !  so the corresponding DATA values are in increasing order.  The pivot key, DATAP, is then DATA[P].

      p=(l+r)/2
      indexp=indx(p)
      datap=data(indexp)

      if (data(indx(l)) .gt. datap) then
         indx(p)=indx(l)
         indx(l)=indexp
         indexp=indx(p)
         datap=data(indexp)
      endif

      if (datap .gt. data(indx(r))) then

         if (data(indx(l)) .gt. data(indx(r))) then
            indx(p)=indx(l)
            indx(l)=indx(r)
         else
            indx(p)=indx(r)
         endif

         indx(r)=indexp
         indexp=indx(p)
         datap=data(indexp)
      endif

      !  Now we swap values between the right and left sides and/or move DATAP until all smaller values are on the left and all
      !  larger values are on the right.  Neither the left or right side will be internally ordered yet; however, DATAP will be
      !  in its final position.
      Q3: do
         ! Q3: Search for datum on left >= DATAP
         !   At this point, DATA[L] <= DATAP.  We can therefore start scanning up from L, looking for a value >= DATAP
         !   (this scan is guaranteed to terminate since we initially placed DATAP near the middle of the subsequence).
         I=I+1
         if (data(indx(i)).lt.datap)then
            cycle Q3
         endif
         !-----------------------------------------------------------------------------------------------------------------------
         ! Q4: Search for datum on right <= DATAP
         !
         !   At this point, DATA[R] >= DATAP.  We can therefore start scanning down from R, looking for a value <= DATAP
         !   (this scan is guaranteed to terminate since we initially placed DATAP near the middle of the subsequence).
         Q4: do
            j=j-1
            if (data(indx(j)).le.datap) then
               exit Q4
            endif
         enddo Q4
         !-----------------------------------------------------------------------------------------------------------------------
         ! Q5: Have the two scans collided?
         if (i.lt.j) then
            ! Q6: No, interchange DATA[I] <--> DATA[J] and continue
            indext=indx(i)
            indx(i)=indx(j)
            indx(j)=indext
            cycle Q3
         else
            ! Q7: Yes, select next subsequence to sort
            !   At this point, I >= J and DATA[l] <= DATA[I] == DATAP <= DATA[r], for all L <= l < I and J < r <= R.
         !   If both subsequences are more than M elements long, push the longer one on the stack
            !   and go back to QuickSort the shorter; if only one is more than M elements long, go back and QuickSort it;
         !   otherwise, pop a subsequence off the stack and QuickSort it.
            if (r-j .ge. i-l .and. i-l .gt. m) then
               istk=istk+1
               lstk(istk)=j+1
               rstk(istk)=r
               r=i-1
            else if (i-l .gt. r-j .and. r-j .gt. m) then
               istk=istk+1
               lstk(istk)=l
               rstk(istk)=i-1
               l=j+1
            else if (r-j .gt. m) then
               l=j+1
            else if (i-l .gt. m) then
               r=i-1
            else
               ! Q8: Pop the stack, or terminate QuickSort if empty
               if (istk.lt.1) then
                  exit TOP
               endif
               l=lstk(istk)
               r=rstk(istk)
               istk=istk-1
            endif
            cycle TOP
         endif
         ! never get here, as cycle Q3 or cycle TOP
      enddo Q3
      exit TOP
   enddo TOP
endif
!===================================================================================================================================
! Q9: Straight Insertion sort
do i=2,n
   if (data(indx(i-1)) .gt. data(indx(i))) then
      indexp=indx(i)
      datap=data(indexp)
      p=i-1
      INNER: do
         indx(p+1) = indx(p)
         p=p-1
         if (p.le.0)then
            exit INNER
         endif
         if (data(indx(p)).le.datap)then
            exit INNER
         endif
      enddo INNER
      indx(p+1) = indexp
   endif
enddo
!===================================================================================================================================
!     All done
end subroutine sort_quick_rx_real
!==================================================================================================================================!
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()!
!==================================================================================================================================!
!>
!!##NAME
!!    unique(3f) - [M_sort] assuming an array is sorted, return array with duplicate values removed
!!    (LICENSE:PD)
!!##SYNOPSIS
!!
!!    subroutine unique(array,ivals)
!!
!!     class(*),intent(inout)  :: array(:)
!!     integer,intent(out)     :: ivals
!!
!!##DESCRIPTION
!!     Assuming an array is sorted, return the array with duplicate values removed.
!!
!!##OPTIONS
!!    array      may be of type INTEGER, REAL, CHARACTER, COMPLEX, DOUBLEPRECISION,
!!               or complex doubleprecision (that is, complex(kind=kind(0.0d0)) ).
!!    ivals      number of unique values packed into beginning of array
!!##EXAMPLE
!!
!!    Sample program
!!
!!     program demo_unique
!!     use M_sort, only : unique
!!     implicit none
!!     character(len=:),allocatable :: strings(:)
!!     integer                      :: icount
!!
!!     strings=[character(len=2) :: '1','1','2','3','4','4','10','20','20','30']
!!     write(*,'(a,*(a3,1x))')'ORIGINAL:',strings
!!     write(*,'("SIZE=",i0)')size(strings)
!!
!!     call unique(strings,icount)
!!
!!     write(*,*)
!!     write(*,'(a,*(a3,1x))')'AFTER   :',strings(1:icount)(:2)
!!     write(*,'("SIZE=",i0)')size(strings)
!!     write(*,'("ICOUNT=",i0)')icount
!!
!!     end program demo_unique
!!
!!    Expected output
!!
!!     ORIGINAL: 1   1   2   3   4   4   10  20  20  30
!!     SIZE=10
!!
!!     AFTER   : 1   2   3   4   10  20  30
!!     SIZE=10
!!     ICOUNT=7
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine unique_integers(array,ivals)
integer,intent(inout)  :: array(:)
integer,intent(out)    :: ivals
   integer             :: i,isize
   isize=size(array)
   if(isize.ge.2)then
      ivals=1
      do i=2,isize
         if(array(i).ne.array(i-1))then
            ivals=ivals+1
            array(ivals)=array(i)
         endif
      enddo
   else
      ivals=isize
   endif
end subroutine unique_integers
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine unique_reals(array,ivals)
real,intent(inout)  :: array(:)
integer,intent(out) :: ivals
   integer          :: i,isize
   isize=size(array)
   if(isize.ge.2)then
      ivals=1
      do i=2,isize
        if(array(i).ne.array(i-1))then
           ivals=ivals+1
           array(ivals)=array(i)
        endif
      enddo
   else
      ivals=isize
   endif
end subroutine unique_reals
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine unique_strings_allocatable_len(array,ivals)
character(len=:),intent(inout),allocatable  :: array(:)
integer,intent(out)                         :: ivals
   integer                                  :: i,isize
   isize=size(array)
   if(isize.ge.2)then
      ivals=1
      do i=2,isize
        if(array(i).ne.array(i-1))then
           ivals=ivals+1
           array(ivals)=array(i)
        endif
      enddo
   else
      ivals=isize
   endif
end subroutine unique_strings_allocatable_len
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine unique_strings(array,ivals)
character(len=*),intent(inout),allocatable  :: array(:)
integer,intent(out)                         :: ivals
   integer                                  :: i,isize
   isize=size(array)
   if(isize.ge.2)then
      ivals=1
      do i=2,isize
        if(array(i).ne.array(i-1))then
           ivals=ivals+1
           array(ivals)=array(i)
        endif
      enddo
   else
      ivals=isize
   endif
end subroutine unique_strings
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine unique_allocatable_strings(array,ivals)
character(len=:),intent(inout),allocatable  :: array(:)
integer,intent(out)                         :: ivals
   integer                                  :: i,isize
   isize=size(array)
   if(isize.ge.2)then
      ivals=1
      do i=2,isize
        if(array(i).ne.array(i-1))then
           ivals=ivals+1
           array(ivals)=array(i)
        endif
      enddo
   else
      ivals=isize
   endif
end subroutine unique_allocatable_strings
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine unique_complex(array,ivals)
complex,intent(inout)  :: array(:)
integer,intent(out)    :: ivals
   integer             :: i,isize
   isize=size(array)
   if(isize.ge.2)then
      ivals=1
      do i=2,isize
        if(array(i).ne.array(i-1))then
           ivals=ivals+1
           array(ivals)=array(i)
        endif
      enddo
   else
      ivals=isize
   endif
end subroutine unique_complex
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine unique_doubles(array,ivals)
doubleprecision,intent(inout)  :: array(:)
integer,intent(out)            :: ivals
   integer                     :: i,isize
   isize=size(array)
   if(isize.ge.2)then
      ivals=1
      do i=2,isize
        if(array(i).ne.array(i-1))then
           ivals=ivals+1
           array(ivals)=array(i)
        endif
      enddo
   else
      ivals=isize
   endif
end subroutine unique_doubles
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
subroutine unique_complex_double(array,ivals)
complex(kind=cd),intent(inout) :: array(:)   ! array  input/output array
integer,intent(out)            :: ivals
   integer                     :: i,isize
   isize=size(array)
   if(isize.ge.2)then
      ivals=1
      do i=2,isize
        if(array(i).ne.array(i-1))then
           ivals=ivals+1
           array(ivals)=array(i)
        endif
      enddo
   else
      ivals=isize
   endif
end subroutine unique_complex_double
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
!>
!! DESCRIPTION: swap(3f):subroutine swaps two variables of like type (real,integer,complex,character,double)
!!##VERSION:     1.0 19970201
!! AUTHOR:      John S. Urban
!!
!!     M_sort::swap(3f): swap two variables of like type (real,integer,complex,character,double)
!!
!!     SWAP is a Generic Interface in a module with PRIVATE specific procedures.
!!     This means the individual subroutines cannot be called from outside of the M_sort(3fm) module.
!!
!!      o procedure names are declared private in this module so they are not accessible except by their generic name
!!      o procedures must include a "use M_sort" to access the generic name "swap"
!!      o if these routines are recompiled, routines with the USE statement should then be recompiled and reloaded.
!===================================================================================================================================
!>
!!##NAME
!!    swap(3f) - [M_sort] elemental subroutine swaps two standard type variables of like type
!!    (LICENSE:PD)
!!##SYNOPSIS
!!
!!    subroutine swap(X,Y)
!!##DESCRIPTION
!!    Generic subroutine SWAP(GEN1,GEN2) swaps two variables of like type
!!    (real, integer, complex, character, double, logical).
!!
!!    On output, the values of X and Y have been interchanged.
!!    Swapping is commonly required in procedures that sort data.
!!
!!    SWAP(3f) is elemental, so it can operate on vectors and arrays as well
!!    as scalar values.
!!
!!##EXAMPLE
!!
!!   Example program:
!!
!!    program demo_swap
!!    use M_sort, only : swap
!!    integer             :: iarray(2)=[10,20]
!!    real                :: rarray(2)=[11.11,22.22]
!!    doubleprecision     :: darray(2)=[1234.56789d0,9876.54321d0]
!!    complex             :: carray(2)=[(1234,56789),(9876,54321)]
!!    logical             :: larray(2)=[.true.,.false.]
!!    character(len=16)   :: string(2)=["First string    ","The other string"]
!!
!!    integer             :: one(13)=1
!!    integer             :: two(13)=2
!!
!!    integer             :: one2(3,3)=1
!!    integer             :: two2(3,3)=2
!!
!!       print *, "integers before swap ", iarray
!!       call swap (iarray(1), iarray(2))
!!       print *, "integers after swap  ", iarray
!!
!!       print *, "reals before swap ", rarray
!!       call swap (rarray(1), rarray(2))
!!       print *, "reals after swap  ", rarray
!!
!!       print *, "doubles before swap ", darray
!!       call swap (darray(1), darray(2))
!!       print *, "doubles after swap  ", darray
!!
!!       print *, "complexes before swap ", carray
!!       call swap (carray(1), carray(2))
!!       print *, "complexes after swap  ", carray
!!
!!       print *, "logicals before swap ", larray
!!       call swap (larray(1), larray(2))
!!       print *, "logicals after swap  ", larray
!!
!!       print *, "strings before swap ", string
!!       call swap (string(1), string(2))
!!       print *, "strings after swap ", string
!!
!!       write(*,*)'swap two vectors'
!!       write(*,'("one before: ",*(i0,:","))') one
!!       write(*,'("two before: ",*(i0,:","))') two
!!       call swap(one,two)
!!       write(*,'("one after: ",*(i0,:","))') one
!!       write(*,'("two after: ",*(i0,:","))') two
!!
!!       write(*,*)'given these arrays initially each time '
!!       one2=1
!!       two2=2
!!       call printarrays()
!!
!!       write(*,*)'swap two rows'
!!       one2=1
!!       two2=2
!!       call swap(one2(2,:),two2(3,:))
!!       call printarrays()
!!
!!       write(*,*)'swap two columns'
!!       one2=1
!!       two2=2
!!       call swap(one2(:,2),two2(:,2))
!!       call printarrays()
!!
!!       write(*,*)'swap two arrays with same number of elements'
!!       one2=1
!!       two2=2
!!       call swap(one2,two2)
!!       call printarrays()
!!
!!       contains
!!       subroutine printarrays()
!!       integer :: i
!!       do i=1,size(one2(1,:))
!!          write(*,'(*(i0,:","))') one2(i,:)
!!       enddo
!!       write(*,*)
!!       do i=1,size(two2(1,:))
!!          write(*,'(*(i0,:","))') two2(i,:)
!!       enddo
!!       end subroutine printarrays
!!
!!    end program demo_swap
!!
!!   Expected Results:
!!
!!    > integers before swap           10          20
!!    > integers after swap            20          10
!!    > reals before swap    11.1099997       22.2199993
!!    > reals after swap     22.2199993       11.1099997
!!    > doubles before swap    1234.5678900000000        9876.5432099999998
!!    > doubles after swap     9876.5432099999998        1234.5678900000000
!!    > complexes before swap  (  1234.00000    ,  56789.0000    ) (  9876.00000    ,  54321.0000    )
!!    > complexes after swap   (  9876.00000    ,  54321.0000    ) (  1234.00000    ,  56789.0000    )
!!    > logicals before swap  T F
!!    > logicals after swap   F T
!!    > strings before swap First string    The other string
!!    > strings after swap The other stringFirst string
!!    > swap two vectors
!!    >one before: 1,1,1,1,1,1,1,1,1,1,1,1,1
!!    >two before: 2,2,2,2,2,2,2,2,2,2,2,2,2
!!    >one after: 2,2,2,2,2,2,2,2,2,2,2,2,2
!!    >two after: 1,1,1,1,1,1,1,1,1,1,1,1,1
!!    > given these arrays initially each time
!!    >1,1,1
!!    >1,1,1
!!    >1,1,1
!!    >
!!    >2,2,2
!!    >2,2,2
!!    >2,2,2
!!    > swap two rows
!!    >1,1,1
!!    >2,2,2
!!    >1,1,1
!!    >
!!    >2,2,2
!!    >2,2,2
!!    >1,1,1
!!    > swap two columns
!!    >1,2,1
!!    >1,2,1
!!    >1,2,1
!!    >
!!    >2,1,2
!!    >2,1,2
!!    >2,1,2
!!    > swap two arrays with same number of elements
!!    >2,2,2
!!    >2,2,2
!!    >2,2,2
!!    >
!!    >1,1,1
!!    >1,1,1
!!    >1,1,1
!===================================================================================================================================
elemental subroutine d_swap(x,y)
! ident_27="@(#)M_sort::d_swap(3fp): swap two double variables"
doubleprecision, intent(inout) :: x,y
doubleprecision                :: temp
   temp = x; x = y; y = temp
end subroutine d_swap
!===================================================================================================================================
elemental subroutine r_swap(x,y)
! ident_28="@(#)M_sort::r_swap(3fp): swap two real variables"
real, intent(inout) :: x,y
real                :: temp
   temp = x; x = y; y = temp
end subroutine r_swap
!===================================================================================================================================
elemental subroutine i_swap(i,j)
! ident_29="@(#)M_sort::i_swap(3fp): swap two integer variables"
integer, intent(inout) :: i,j
integer                :: itemp
   itemp = i; i = j; j = itemp
end subroutine i_swap
!===================================================================================================================================
elemental subroutine l_swap(l,ll)
! ident_30="@(#)M_sort::l_swap(3fp): swap two logical variables"
logical, intent(inout) :: l,ll
logical                :: ltemp
   ltemp = l; l = ll; ll = ltemp
end subroutine l_swap
!===================================================================================================================================
elemental subroutine c_swap(xx,yy)
! ident_31="@(#)M_sort::c_swap(3fp): swap two complex variables"
complex, intent(inout) :: xx,yy
complex                :: tt
   tt = xx; xx = yy; yy = tt
end subroutine c_swap
!===================================================================================================================================
elemental subroutine cd_swap(xx,yy)
! ident_32="@(#)M_sort::cd_swap(3fp): swap two double complex variables"
complex(kind=cd), intent(inout) :: xx,yy
complex(kind=cd)                :: tt
   tt = xx; xx = yy; yy = tt
end subroutine cd_swap
!===================================================================================================================================
elemental subroutine s_swap(string1,string2)

!>
!!   F90 NOTE:
!!    string_temp is an automatic character object whose size is not a constant expression.
!!    Automatic objects cannot be saved or initialized.
!!    Note that the len of a dummy argument can be used to calculate the automatic variable length.
!!    Therefore, you can make sure len is at least max(len(string1),len(string2)) by adding the two lengths together:

! ident_33="@(#)M_sort::s_swap(3fp): swap two double variables"
character(len=*), intent(inout)             :: string1,string2
!character( len=len(string1) + len(string2)) :: string_temp
character( len=max(len(string1),len(string2))) :: string_temp
   string_temp = string1; string1 = string2; string2 = string_temp
end subroutine s_swap
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
!-$DOCUMENT COMMENT -file exchange.3m_sort.man
!-NAME
!-   exchange(3f) - [M_sort] subroutine exchanges two variables of like type
!-   (LICENSE:PD)
!-SYNOPSIS
!-   subroutine exchange(X,Y)
!-DESCRIPTION
!-   Generic subroutine exchange(GEN1,GEN2) exchanges two variables of
!-   like type.
!-
!-   On output, the values of X and Y have been interchanged. Swapping is
!-   commonly required in procedures that sort data.
!-
!-   This routine uses the memcpy(3c) procedure, so data is assumed to be
!-   contiguous and to not overlap.
!-
!-   DO NOT CURRENTLY USE WITH CHARACTER VALUES WITH gfortran, and do not
!-   use with anything but scalar values.
!-
!-EXAMPLE
!-  Example program:
!-
!-   program demo_exchange
!-   use M_sort, only : exchange
!-   integer             :: iarray(2)=[10,20]
!-   real                :: rarray(2)=[11.11,22.22]
!-   doubleprecision     :: darray(2)=[1234.56789d0,9876.54321d0]
!-   complex             :: carray(2)=[(1234,56789),(9876,54321)]
!-   logical             :: larray(2)=[.true.,.false.]
!-   character(len=16)   :: string(2)=["First string    ","The other string"]
!-
!-   integer             :: one(13)=1
!-   integer             :: two(13)=2
!-
!-   integer             :: one2(3,3)=1
!-   integer             :: two2(3,3)=2
!-
!-      print *, "integers before exchange ", iarray
!-      call exchange (iarray(1), iarray(2))
!-      print *, "integers after exchange  ", iarray
!-
!-      print *, "reals before exchange ", rarray
!-      call exchange (rarray(1), rarray(2))
!-      print *, "reals after exchange  ", rarray
!-
!-      print *, "doubles before exchange ", darray
!-      call exchange (darray(1), darray(2))
!-      print *, "doubles after exchange  ", darray
!-
!-      print *, "complexes before exchange ", carray
!-      call exchange (carray(1), carray(2))
!-      print *, "complexes after exchange  ", carray
!-
!-      print *, "logicals before exchange ", larray
!-      call exchange (larray(1), larray(2))
!-      print *, "logicals after exchange  ", larray
!-
!-      write(*,*)'GETS THIS WRONG IN GFORTRAN'
!-      print *, "strings before exchange ", string
!-      call exchange (string(1), string(2))
!-      print *, "strings after exchange ", string
!-
!-      write(*,*)'exchange two vectors'
!-      write(*,'("one before: ",*(i0,:","))') one
!-      write(*,'("two before: ",*(i0,:","))') two
!-      call exchange(one,two)
!-      write(*,'("one after: ",*(i0,:","))') one
!-      write(*,'("two after: ",*(i0,:","))') two
!-
!-      write(*,*)'given these arrays initially each time '
!-      one2=1
!-      two2=2
!-      call printarrays()
!-
!-      write(*,*)'GETS THIS WRONG'
!-      write(*,*)'exchange two rows'
!-      one2=1
!-      two2=2
!-      call exchange(one2(2,:),two2(3,:))
!-      call printarrays()
!-
!-      write(*,*)'GETS THIS WRONG'
!-      write(*,*)'exchange two columns'
!-      one2=1
!-      two2=2
!-      call exchange(one2(:,2),two2(:,2))
!-      call printarrays()
!-
!-      write(*,*)'CANNOT DO MULTI-DIMENSIONAL ARRAYS YET'
!-      write(*,*)'exchange two arrays with same number of elements'
!-      one2=1
!-      two2=2
!-      !call exchange(one2,two2)
!-      !call printarrays()
!-
!-      contains
!-      subroutine printarrays()
!-      integer :: i
!-      do i=1,size(one2(1,:))
!-         write(*,'(*(i0,:","))') one2(i,:)
!-      enddo
!-      write(*,*)
!-      do i=1,size(two2(1,:))
!-         write(*,'(*(i0,:","))') two2(i,:)
!-      enddo
!-      end subroutine printarrays
!-
!-   end program demo_exchange
!-
!-  Expected Results:
!-
!-   > integers before exchange           10          20
!-   > integers after exchange            20          10
!-   > reals before exchange    11.1099997       22.2199993
!-   > reals after exchange     22.2199993       11.1099997
!-   > doubles before exchange    1234.5678900000000        9876.5432099999998
!-   > doubles after exchange     9876.5432099999998        1234.5678900000000
!-   > complexes before exchange  (  1234.00000    ,  56789.0000    ) (  9876.00000    ,  54321.0000    )
!-   > complexes after exchange   (  9876.00000    ,  54321.0000    ) (  1234.00000    ,  56789.0000    )
!-   > logicals before exchange  T F
!-   > logicals after exchange   F T
!-   > strings before exchange First string    The other string
!-   > strings after exchange The other stringFirst string
!-   > exchange two vectors
!-   >one before: 1,1,1,1,1,1,1,1,1,1,1,1,1
!-   >two before: 2,2,2,2,2,2,2,2,2,2,2,2,2
!-   >one after: 2,2,2,2,2,2,2,2,2,2,2,2,2
!-   >two after: 1,1,1,1,1,1,1,1,1,1,1,1,1
!-   > given these arrays initially each time
!-   >1,1,1
!-   >1,1,1
!-   >1,1,1
!-   >
!-   >2,2,2
!-   >2,2,2
!-   >2,2,2
!-   > exchange two rows
!-   >1,1,1
!-   >2,2,2
!-   >1,1,1
!-   >
!-   >2,2,2
!-   >2,2,2
!-   >1,1,1
!-   > exchange two columns
!-   >1,2,1
!-   >1,2,1
!-   >1,2,1
!-   >
!-   >2,1,2
!-   >2,1,2
!-   >2,1,2
!-   > exchange two arrays with same number of elements
!-   >2,2,2
!-   >2,2,2
!-   >2,2,2
!-   >
!-   >1,1,1
!-   >1,1,1
!-   >1,1,1
!-
!-$DOCUMENT END
!-subroutine exchange_scalar(lhs,rhs)
!-use iso_c_binding, only : c_ptr, c_size_t
!-use M_system,      only : system_memcpy
!-implicit none
!-class(*),intent(inout) :: lhs, rhs
!-class(*), allocatable :: temp
!-type(c_ptr) :: tmp
!-   temp=lhs
!-   if(same_type_as(lhs,rhs))then
!-      call system_memcpy(loc(lhs),  loc(rhs), storage_size(lhs,kind=c_size_t)/8_c_size_t )
!-      call system_memcpy(loc(rhs), loc(temp), storage_size(rhs,kind=c_size_t)/8_c_size_t )
!-   else
!-      write(*,*)'error: exchange(3f) called with values of different type'
!-      stop 4
!-   endif
!-end subroutine exchange_scalar
!===================================================================================================================================
!-subroutine exchange_array(lhs,rhs)
!-class(*) :: lhs(:),rhs(:)
!-integer  :: i
!-   if(size(lhs).eq.size(rhs))then
!-      do i=1,size(lhs)
!-         call exchange_scalar(lhs(i),rhs(i))
!-      enddo
!-   else
!-      write(*,*)'error: exchange(3f) called with arrays of different sizes'
!-      stop 5
!-   endif
!-end subroutine exchange_array
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
!>
!!##NAME
!!    swap_any(3f) - [M_sort] subroutine swaps two variables of like type
!!    (LICENSE:PD)
!!##SYNOPSIS
!!
!!    subroutine swap_any(X,Y)
!!##DESCRIPTION
!!    Generic subroutine swap_any(GEN1,GEN2) swap_anys two variables of
!!    like type.
!!
!!    On output, the values of X and Y have been interchanged. Swapping is
!!    commonly required in procedures that sort data.
!!
!!    DO NOT CURRENTLY USE WITH ANYTHING BUT SCALAR VALUES.
!!
!!##EXAMPLE
!!
!!   Example program:
!!
!!    program demo_swap_any
!!    use M_sort, only : swap_any
!!    integer             :: iarray(2)=[10,20]
!!    real                :: rarray(2)=[11.11,22.22]
!!    doubleprecision     :: darray(2)=[1234.56789d0,9876.54321d0]
!!    complex             :: carray(2)=[(1234,56789),(9876,54321)]
!!    logical             :: larray(2)=[.true.,.false.]
!!    character(len=16)   :: string(2)=["First string    ","The other string"]
!!
!!    integer             :: one(13)=1
!!    integer             :: two(13)=2
!!
!!    integer             :: one2(3,3)=1
!!    integer             :: two2(3,3)=2
!!
!!       print *, "integers before swap_any ", iarray
!!       call swap_any (iarray(1), iarray(2))
!!       print *, "integers after swap_any  ", iarray
!!
!!       print *, "reals before swap_any ", rarray
!!       call swap_any (rarray(1), rarray(2))
!!       print *, "reals after swap_any  ", rarray
!!
!!       print *, "doubles before swap_any ", darray
!!       call swap_any (darray(1), darray(2))
!!       print *, "doubles after swap_any  ", darray
!!
!!       print *, "complexes before swap_any ", carray
!!       call swap_any (carray(1), carray(2))
!!       print *, "complexes after swap_any  ", carray
!!
!!       print *, "logicals before swap_any ", larray
!!       call swap_any (larray(1), larray(2))
!!       print *, "logicals after swap_any  ", larray
!!
!!       print *, "strings before swap_any ", string
!!       call swap_any (string(1), string(2))
!!       print *, "strings after swap_any ", string
!!
!!       write(*,*)'swap_any two vectors'
!!       write(*,'("one before: ",*(i0,:","))') one
!!       write(*,'("two before: ",*(i0,:","))') two
!!       call swap_any(one,two)
!!       write(*,'("one after: ",*(i0,:","))') one
!!       write(*,'("two after: ",*(i0,:","))') two
!!
!!       write(*,*)'given these arrays initially each time '
!!       one2=1
!!       two2=2
!!       call printarrays()
!!
!!       write(*,*)'GETS THIS WRONG'
!!       write(*,*)'swap_any two rows'
!!       one2=1
!!       two2=2
!!       call swap_any(one2(2,:),two2(3,:))
!!       call printarrays()
!!
!!       write(*,*)'GETS THIS WRONG'
!!       write(*,*)'swap_any two columns'
!!       one2=1
!!       two2=2
!!       call swap_any(one2(:,2),two2(:,2))
!!       call printarrays()
!!
!!       write(*,*)'CANNOT DO MULTI-DIMENSIONAL ARRAYS YET'
!!       write(*,*)'swap_any two arrays with same number of elements'
!!       one2=1
!!       two2=2
!!       !call swap_any(one2,two2)
!!       !call printarrays()
!!
!!       contains
!!       subroutine printarrays()
!!       integer :: i
!!       do i=1,size(one2(1,:))
!!          write(*,'(*(i0,:","))') one2(i,:)
!!       enddo
!!       write(*,*)
!!       do i=1,size(two2(1,:))
!!          write(*,'(*(i0,:","))') two2(i,:)
!!       enddo
!!       end subroutine printarrays
!!
!!    end program demo_swap_any
!!
!!   Expected Results:
!!
!!    > integers before swap_any           10          20
!!    > integers after swap_any            20          10
!!    > reals before swap_any    11.1099997       22.2199993
!!    > reals after swap_any     22.2199993       11.1099997
!!    > doubles before swap_any    1234.5678900000000        9876.5432099999998
!!    > doubles after swap_any     9876.5432099999998        1234.5678900000000
!!    > complexes before swap_any  (  1234.00000    ,  56789.0000    ) (  9876.00000    ,  54321.0000    )
!!    > complexes after swap_any   (  9876.00000    ,  54321.0000    ) (  1234.00000    ,  56789.0000    )
!!    > logicals before swap_any  T F
!!    > logicals after swap_any   F T
!!    > strings before swap_any First string    The other string
!!    > strings after swap_any The other stringFirst string
!!    > swap_any two vectors
!!    >one before: 1,1,1,1,1,1,1,1,1,1,1,1,1
!!    >two before: 2,2,2,2,2,2,2,2,2,2,2,2,2
!!    >one after: 2,2,2,2,2,2,2,2,2,2,2,2,2
!!    >two after: 1,1,1,1,1,1,1,1,1,1,1,1,1
!!    > given these arrays initially each time
!!    >1,1,1
!!    >1,1,1
!!    >1,1,1
!!    >
!!    >2,2,2
!!    >2,2,2
!!    >2,2,2
!!    > swap_any two rows
!!    >1,1,1
!!    >2,2,2
!!    >1,1,1
!!    >
!!    >2,2,2
!!    >2,2,2
!!    >1,1,1
!!    > swap_any two columns
!!    >1,2,1
!!    >1,2,1
!!    >1,2,1
!!    >
!!    >2,1,2
!!    >2,1,2
!!    >2,1,2
!!    > swap_any two arrays with same number of elements
!!    >2,2,2
!!    >2,2,2
!!    >2,2,2
!!    >
!!    >1,1,1
!!    >1,1,1
!!    >1,1,1
subroutine swap_any_scalar( lhs, rhs )
class(*) :: rhs
class(*) :: lhs
character(len=1),allocatable :: templ(:)
character(len=1),allocatable :: tempr(:)
   tempr=anything_to_bytes(rhs)
   templ=anything_to_bytes(lhs)
   call bytes_to_anything(templ,rhs)
   call bytes_to_anything(tempr,lhs)
end subroutine swap_any_scalar
!-----------------------------------------------------------------------------------------------------------------------------------
subroutine swap_any_array( lhs, rhs )
class(*) :: rhs(:)
class(*) :: lhs(:)
integer  :: i
   do i=1,size(lhs)
      call swap_any_scalar(lhs(i),rhs(i))
   enddo
end subroutine swap_any_array
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
!
! XXXXXXX XXXXXX  XXXXXXX XXXXXXX
! X  X  X  X    X  X    X  X    X
!    X     X    X  X       X
!    X     X    X  X  X    X  X
!    X     XXXXX   XXXX    XXXX
!    X     X  X    X  X    X  X
!    X     X  X    X       X
!    X     X   X   X    X  X    X
!   XXX   XXX  XX XXXXXXX XXXXXXX
!
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
!>
!!##NAME
!!    tree_insert(3f) - [M_sort] sort a number of integers by building a tree, sorted in infix order
!!    (LICENSE:MIT)
!!##SYNOPSIS
!!
!!   subroutine tree_insert(t,number)
!!
!!    type(tree_node), pointer :: t
!!    integer             :: number
!!
!!##DESCRIPTION
!!   Sorts a number of integers by building a tree, sorted in infix order.
!!   This sort has expected behavior n log n, but worst case (input is
!!   sorted) n ** 2.
!!
!!##AUTHOR
!!   Copyright (c) 1990 by Walter S. Brainerd, Charles H. Goldberg,
!!   and Jeanne C. Adams. This code may be copied and used without
!!   restriction as long as this notice is retained.
!!
!!##EXAMPLE
!!
!!  sample program
!!
!!    program tree_sort
!!    use M_sort, only : tree_node, tree_insert, tree_print
!!    implicit none
!!    type(tree_node), pointer :: t     ! A tree
!!    integer             :: number
!!    integer             :: ios
!!    nullify(t)                        ! Start with empty tree
!!    infinite: do
!!       read (*,*,iostat=ios) number
!!       if(ios.ne.0)exit infinite
!!       call tree_insert(t,number)     ! Put next number in tree
!!    enddo infinite
!!    call tree_print(t)                ! Print nodes of tree in infix order
!!    end program tree_sort
recursive subroutine tree_insert (t, number)
implicit none

! ident_34="@(#)M_sort::tree_insert(3f): sort a number of integers by building a tree, sorted in infix order"

type (tree_node), pointer :: t  ! a tree
integer, intent (in) :: number
   ! if (sub)tree is empty, put number at root
   if (.not. associated (t)) then
      allocate (t)
      t % value = number
      nullify (t % left)
      nullify (t % right)
      ! otherwise, insert into correct subtree
   else if (number < t % value) then
      call tree_insert (t % left, number)
   else
      call tree_insert (t % right, number)
   endif
end subroutine tree_insert
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
!>
!!##NAME
!!    tree_print(3f) - [M_sort] print a sorted integer tree generated by tree_insert(3f)
!!    (LICENSE:MIT)
!!##SYNOPSIS
!!
!!   subroutine tree_print(t)
!!
!!    type(tree_node), pointer :: t
!!
!!##DESCRIPTION
!!   Print a tree of sorted integers created by insert_tree(3f).
!!
!!##AUTHOR
!!   Copyright (c) 1990 by Walter S. Brainerd, Charles H. Goldberg,
!!   and Jeanne C. Adams. This code may be copied and used without
!!   restriction as long as this notice is retained.
!!
!!##EXAMPLE
!!
!!  sample program
!!
!!    program tree_sort
!!    use M_sort, only : tree_node, tree_insert, tree_print
!!    implicit none
!!    type(tree_node), pointer :: t     ! A tree
!!    integer             :: number
!!    integer             :: ios
!!    nullify(t)                        ! Start with empty tree
!!    infinite: do
!!       read (*,*,iostat=ios) number
!!       if(ios.ne.0)exit infinite
!!       call tree_insert(t,number)     ! Put next number in tree
!!    enddo infinite
!!    call tree_print(t)                ! Print nodes of tree in infix order
!!    end program tree_sort
recursive subroutine tree_print(t)
implicit none

! ident_35="@(#)M_sort::tree_print(3f):"

type (tree_node), pointer :: t  ! a tree

   if (associated (t)) then
      call tree_print (t % left)
      print *, t % value
      call tree_print (t % right)
   endif
end subroutine tree_print
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
!>
!!##NAME
!!    anything_to_bytes(3f) - [M_sort] convert standard types to bytes (character(len=1):: array(:))
!!    (LICENSE:PD)
!!
!!##SYNOPSIS
!!
!!    function anything_to_bytes_arr(anything) result(chars)
!!
!!     class(*),intent(in)  :: anything
!!             or
!!     class(*),intent(in)  :: anything(:)
!!
!!     character(len=1),allocatable :: chars(:)
!!
!!##DESCRIPTION
!!
!!    This function uses polymorphism to allow input arguments of different
!!    types. It is used to create other procedures that can take many
!!    argument types as input options and convert them to a single type
!!    to simplify storing arbitrary data, to simplify generating data
!!    hashes, ...
!!
!!##OPTIONS
!!
!!    VALUEIN  input array or scalar to convert to type CHARACTER(LEN=1).
!!             May be of KIND INTEGER(kind=int8), INTEGER(kind=int16),
!!             INTEGER(kind=int32), INTEGER(kind=int64),
!!             REAL(kind=real32, REAL(kind=real64),
!!             REAL(kind=real128), complex, or CHARACTER(len=*)
!!##RETURN
!!
!!    CHARS    The returned value is an array of bytes (character(len=1)).
!!
!!##EXAMPLE
!!
!!
!!   Sample program
!!
!!    program demo_anything_to_bytes
!!    use M_sort,      only : anything_to_bytes
!!    !!use, intrinsic :: iso_fortran_env, only : int8, int16, int32, int64
!!    !!use, intrinsic :: iso_fortran_env, only : real32, real64, real128
!!    implicit none
!!    integer :: i
!!       write(*,'(/,4(1x,z2.2))')anything_to_bytes([(i*i,i=1,10)])
!!       write(*,'(/,4(1x,z2.2))')anything_to_bytes([11.11,22.22,33.33])
!!       write(*,'(/,4(1x,z2.2))')anything_to_bytes('This is a string')
!!    end program demo_anything_to_bytes
!!
!!   Expected output
!!
!!     01 00 00 00
!!     04 00 00 00
!!     09 00 00 00
!!     10 00 00 00
!!     19 00 00 00
!!     24 00 00 00
!!     31 00 00 00
!!     40 00 00 00
!!     51 00 00 00
!!     64 00 00 00
!!
!!     8F C2 31 41
!!     8F C2 B1 41
!!     EC 51 05 42
!!
!!     54 68 69 73
!!     20 69 73 20
!!     61 20 73 74
!!     72 69 6E 67
!!
!!##AUTHOR
!!    John S. Urban
!!##LICENSE
!!    Public Domain
function anything_to_bytes_arr(anything) result(chars)
implicit none

! ident_36="@(#)M_sort::anything_to_bytes_arr(3fp): any vector of intrinsics to bytes (an array of CHARACTER(LEN=1) variables)"

class(*),intent(in)          :: anything(:)
character(len=1),allocatable :: chars(:)
   select type(anything)

    type is (character(len=*));     chars=transfer(anything,chars)
    type is (complex);              chars=transfer(anything,chars)
    type is (complex(kind=dp));     chars=transfer(anything,chars)
    type is (integer(kind=int8));   chars=transfer(anything,chars)
    type is (integer(kind=int16));  chars=transfer(anything,chars)
    type is (integer(kind=int32));  chars=transfer(anything,chars)
    type is (integer(kind=int64));  chars=transfer(anything,chars)
    type is (real(kind=real32));    chars=transfer(anything,chars)
    type is (real(kind=real64));    chars=transfer(anything,chars)
    type is (real(kind=real128));   chars=transfer(anything,chars)
    type is (logical);              chars=transfer(anything,chars)
    class default
      stop 'crud. anything_to_bytes_arr(1) does not know about this type'

   end select
end function anything_to_bytes_arr
!-----------------------------------------------------------------------------------------------------------------------------------
function  anything_to_bytes_scalar(anything) result(chars)
implicit none

! ident_37="@(#)M_sort::anything_to_bytes_scalar(3fp): anything to bytes (an array of CHARACTER(LEN=1) variables)"

class(*),intent(in)          :: anything
character(len=1),allocatable :: chars(:)
   select type(anything)

    type is (character(len=*));     chars=transfer(anything,chars)
    type is (complex);              chars=transfer(anything,chars)
    type is (complex(kind=dp));     chars=transfer(anything,chars)
    type is (integer(kind=int8));   chars=transfer(anything,chars)
    type is (integer(kind=int16));  chars=transfer(anything,chars)
    type is (integer(kind=int32));  chars=transfer(anything,chars)
    type is (integer(kind=int64));  chars=transfer(anything,chars)
    type is (real(kind=real32));    chars=transfer(anything,chars)
    type is (real(kind=real64));    chars=transfer(anything,chars)
    type is (real(kind=real128));   chars=transfer(anything,chars)
    type is (logical);              chars=transfer(anything,chars)
    class default
      stop 'crud. anything_to_bytes_scalar(1) does not know about this type'

   end select
end function  anything_to_bytes_scalar
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
!>
!!##NAME
!!    bytes_to_anything(3f) - [M_sort] convert bytes(character)len=1):: array(:)) to standard types
!!    (LICENSE:PD)
!!
!!##SYNOPSIS
!!
!!   subroutine bytes_to_anything(chars,anything)
!!
!!    character(len=1),allocatable :: chars(:)
!!    class(*) :: anything
!!
!!##DESCRIPTION
!!
!!    This function uses polymorphism to allow input arguments of different
!!    types. It is used to create other procedures that can take many
!!    argument types as input options and convert them to a single type
!!    to simplify storing arbitrary data, to simplify generating data
!!    hashes, ...
!!
!!##OPTIONS
!!    CHARS     The input value is an array of bytes (character(len=1)).
!!
!!##RETURN
!!    ANYTHING  May be of KIND INTEGER(kind=int8), INTEGER(kind=int16),
!!              INTEGER(kind=int32), INTEGER(kind=int64),
!!              REAL(kind=real32, REAL(kind=real64),
!!              REAL(kind=real128), complex, or CHARACTER(len=*)
!!
!!##EXAMPLE
!!
!!
!!   Sample program
!!
!!   Expected output
!!
!!##AUTHOR
!!    John S. Urban
!!##LICENSE
!!    Public Domain
subroutine bytes_to_anything(chars,anything)
   character(len=1),allocatable :: chars(:)
   class(*) :: anything
   select type(anything)
    type is (character(len=*));     anything=transfer(chars,anything)
    type is (complex);              anything=transfer(chars,anything)
    type is (complex(kind=dp));     anything=transfer(chars,anything)
    type is (integer(kind=int8));   anything=transfer(chars,anything)
    type is (integer(kind=int16));  anything=transfer(chars,anything)
    type is (integer(kind=int32));  anything=transfer(chars,anything)
    type is (integer(kind=int64));  anything=transfer(chars,anything)
    type is (real(kind=real32));    anything=transfer(chars,anything)
    type is (real(kind=real64));    anything=transfer(chars,anything)
    type is (real(kind=real128));   anything=transfer(chars,anything)
    type is (logical);              anything=transfer(chars,anything)
    class default
      stop 'crud. bytes_to_anything(1) does not know about this type'
   end select
end subroutine bytes_to_anything
!===================================================================================================================================
!()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()=
!===================================================================================================================================
end module M_sort
!===================================================================================================================================
