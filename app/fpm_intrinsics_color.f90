program testit
use,intrinsic :: iso_fortran_env, only : stdin=>input_unit, stdout=>output_unit, stderr=>error_unit
use M_intrinsics,                 only : help_intrinsics
use M_escape,                     only : attr, esc_mode, esc
use M_strings,                    only : atleast, indent
implicit none
character(len=132), allocatable :: manual(:)
integer                         :: i,j, count, ilen, lead
character(len=30)               :: argument
logical                         :: program_text
    count=command_argument_count()
    if(count.eq.0)then
        manual = help_intrinsics('')
        write(*,'(g0)') ( trim(manual(i)), i=1, size(manual) )
    else
        !if(isatty(stdout))then  ! COMMON FORTRAN EXTENSION
           call esc_mode('color')
        !   call esc_mode('raw')
        !else
        !   call esc_mode('plain')
        !endif
        program_text=.false.
        lead=0
        do i=1, count
            call get_command_argument (count,argument)
            manual = help_intrinsics(argument)
            do j=1,size(manual)
                if( index(manual(j),'end program demo_') .eq. 0 .and. index(manual(j),'program demo_') .ne. 0)then
                   program_text=.true.
                   lead=indent(manual(j))
                endif
                if(program_text .eqv. .true.)then
                    write(*,'(g0)')esc('<C>'//repeat(' ',lead)//'<b><W>'//atleast(manual(j)(lead+1:),80-lead) )
                elseif(verify(manual(j)(1:1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ) == 0 .and. &
                & verify(manual(j), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ _') == 0 )then
                    ilen=len(trim(manual(j)))
                    write(*,'(g0)') esc('<Y><e> '//trim(manual(j))//' <C><b>'//repeat(' ',max(0,80-ilen-2))//'<reset>')
                else
                    write(*,'(g0)') attr('CYAN:black',atleast(trim(manual(j)),80))
                endif
                if( index(manual(j),'end program demo_') .ne.0)then
                   program_text=.false.
                endif
            enddo
        enddo
    endif
end program testit
