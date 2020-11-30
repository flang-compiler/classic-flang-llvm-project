; REQUIRES: object-emission

; Check that DIFortranSubrange works correctly for both local (dummy) and
; global (static) allocatable arrays. The IR in this test is reduced from
; this Fortran program:
;
; subroutine test(larr)
;   real, dimension(:), allocatable, save :: sarr
;   real, dimension(:), allocatable :: larr
;   allocate(sarr(10))
;   allocate(larr(10))
; end subroutine

; RUN: %llc_dwarf -O0 -filetype=obj < %s > %t.o
; RUN: llvm-dwarfdump -debug-info %t.o | FileCheck %s

; CHECK:        DW_TAG_variable
; CHECK:          DW_AT_name	("sarr$sd1")
; CHECK-NEXT:     DW_AT_type	([[SDTYPE:0x[0-9a-f]+]] "integer*8[]")
; CHECK-NEXT:     DW_AT_artificial	(true)
; CHECK-NEXT:     DW_AT_location	(DW_OP_addr 0x{{[0-9a-f]+}}, DW_OP_plus_uconst 0x20)

; CHECK:        DW_TAG_variable
; CHECK:          DW_AT_name	("sarr")
; CHECK-NEXT:     DW_AT_type	([[ATYPE1:0x[0-9a-f]+]] "real[]")
; CHECK-NEXT:     DW_AT_location	(DW_OP_addr 0x{{[0-9a-f]+}}, DW_OP_deref)

; CHECK:        DW_TAG_formal_parameter
; CHECK:          DW_AT_name	("larr$p")
; CHECK-NEXT:     DW_AT_type	([[ATYPE2:0x[0-9a-f]+]] "real[]")
; CHECK-NEXT:     DW_AT_artificial	(true)

; CHECK:        DW_TAG_formal_parameter
; CHECK:          DW_AT_name	("larr$sd")
; CHECK-NEXT:     DW_AT_type	([[SDTYPE]] "integer*8[]")
; CHECK-NEXT:     DW_AT_artificial	(true)

; CHECK: [[SDTYPE]]: DW_TAG_array_type
; CHECK-NEXT:   DW_AT_type	({{.*}} "integer*8")
; CHECK-EMPTY:
; CHECK-NEXT:   DW_TAG_subrange_type
; CHECK-NEXT:     DW_AT_type	({{.*}} "__ARRAY_SIZE_TYPE__")
; CHECK-NEXT:     DW_AT_lower_bound	(1)
; CHECK-NEXT:     DW_AT_upper_bound	(16)

; CHECK: [[ATYPE1]]: DW_TAG_array_type
; CHECK-NEXT:   DW_AT_type	({{.*}} "real")
; CHECK-EMPTY:
; CHECK-NEXT:   DW_TAG_subrange_type
; CHECK-NEXT:     DW_AT_type	({{.*}} "__ARRAY_SIZE_TYPE__")
; CHECK-NEXT:     DW_AT_lower_bound	(DW_OP_addr 0x{{[0-9a-f]+}}, DW_OP_plus_uconst 0x50, DW_OP_deref)
; CHECK-NEXT:     DW_AT_upper_bound	(DW_OP_addr 0x{{[0-9a-f]+}}, DW_OP_dup, DW_OP_plus_uconst 0x50, DW_OP_deref, DW_OP_swap, DW_OP_plus_uconst 0x58, DW_OP_deref, DW_OP_plus, DW_OP_lit1, DW_OP_minus)

; CHECK: [[ATYPE2]]: DW_TAG_array_type
; CHECK-NEXT:   DW_AT_type	({{.*}} "real")
; CHECK-EMPTY:
; CHECK-NEXT:   DW_TAG_subrange_type
; CHECK-NEXT:     DW_AT_type	({{.*}} "__ARRAY_SIZE_TYPE__")

%struct.BSS1 = type <{ [184 x i8] }>

@.BSS1 = internal global %struct.BSS1 zeroinitializer, align 32, !dbg !25, !dbg !28, !dbg !31, !dbg !34, !dbg !37, !dbg !40, !dbg !45

define void @test_(i64* %larr$p, i64* %larr$sd) !dbg !18 {
L.entry:
  call void @llvm.dbg.declare (metadata i64* %larr$p, metadata !20, metadata !21), !dbg !19
  call void @llvm.dbg.declare (metadata i64* %larr$sd, metadata !22, metadata !23), !dbg !19
  ret void, !dbg !46
}

declare void @llvm.dbg.declare(metadata, metadata, metadata)

!llvm.module.flags = !{ !0, !1 }
!llvm.dbg.cu = !{ !4 }

!0 = !{ i32 2, !"Dwarf Version", i32 4 }
!1 = !{ i32 2, !"Debug Info Version", i32 3 }
!2 = !DIFile(filename: "fortran-subrange-allocatable.f90", directory: "/tmp")
!3 = !{ !25, !28, !31, !34, !37, !40, !45 }
!4 = distinct !DICompileUnit(file: !2, language: DW_LANG_Fortran90, producer: "Classic Flang", globals: !3, emissionKind: FullDebug)
!5 = !DILocalVariable(scope: !18, file: !2, type: !15, flags: 64)
!6 = !DIExpression(DW_OP_plus_uconst, 80, DW_OP_deref)
!7 = !DIExpression(DW_OP_dup, DW_OP_plus_uconst, 80, DW_OP_deref, DW_OP_swap, DW_OP_plus_uconst, 88, DW_OP_deref, DW_OP_plus, DW_OP_constu, 1, DW_OP_minus)
!8 = !DIFortranSubrange(lowerBound: !5, lowerBoundExpression: !6, upperBound: !5, upperBoundExpression: !7)
!9 = !DIBasicType(tag: DW_TAG_base_type, name: "real", size: 32, align: 32, encoding: DW_ATE_float)
!10 = !{ !8 }
!11 = !DIFortranArrayType(tag: DW_TAG_array_type, size: 32, align: 32, baseType: !9, elements: !10)
!12 = !DIFortranSubrange(constLowerBound: 1, constUpperBound: 16)
!13 = !DIBasicType(tag: DW_TAG_base_type, name: "integer*8", size: 64, align: 64, encoding: DW_ATE_signed)
!14 = !{ !12 }
!15 = !DIFortranArrayType(tag: DW_TAG_array_type, size: 1024, align: 64, baseType: !13, elements: !14)
!16 = !{ null, !11, !15 }
!17 = !DISubroutineType(types: !16)
!18 = distinct !DISubprogram(file: !2, scope: !4, name: "test", line: 1, type: !17, spFlags: 8, unit: !4, scopeLine: 1)
!19 = !DILocation(scope: !18)
!20 = !DILocalVariable(scope: !18, name: "larr$p", arg: 1, file: !2, type: !11, flags: 64)
!21 = !DIExpression(DW_OP_deref)
!22 = !DILocalVariable(scope: !18, name: "larr$sd", arg: 2, file: !2, type: !15, flags: 64)
!23 = !DIExpression()
!24 = distinct !DIGlobalVariable(scope: !18, name: "z_b_4", file: !2, type: !13, isLocal: true, isDefinition: true, flags: 64)
!25 = !DIGlobalVariableExpression(var: !24, expr: !23)
!26 = distinct !DIGlobalVariable(scope: !18, name: "z_b_5", file: !2, type: !13, isLocal: true, isDefinition: true, flags: 64)
!27 = !DIExpression(DW_OP_plus_uconst, 8)
!28 = !DIGlobalVariableExpression(var: !26, expr: !27)
!29 = distinct !DIGlobalVariable(scope: !18, name: "z_e_38", file: !2, type: !13, isLocal: true, isDefinition: true, flags: 64)
!30 = !DIExpression(DW_OP_plus_uconst, 16)
!31 = !DIGlobalVariableExpression(var: !29, expr: !30)
!32 = distinct !DIGlobalVariable(scope: !18, name: "sarr$sd1", file: !2, type: !15, isLocal: true, isDefinition: true, flags: 64)
!33 = !DIExpression(DW_OP_plus_uconst, 32)
!34 = !DIGlobalVariableExpression(var: !32, expr: !33)
!35 = distinct !DIGlobalVariable(scope: !18, name: "z_b_6", file: !2, type: !13, isLocal: true, isDefinition: true, flags: 64)
!36 = !DIExpression(DW_OP_plus_uconst, 160)
!37 = !DIGlobalVariableExpression(var: !35, expr: !36)
!38 = distinct !DIGlobalVariable(scope: !18, name: "z_b_7", file: !2, type: !13, isLocal: true, isDefinition: true, flags: 64)
!39 = !DIExpression(DW_OP_plus_uconst, 168)
!40 = !DIGlobalVariableExpression(var: !38, expr: !39)
!41 = !DIFortranSubrange(lowerBound: !34, lowerBoundExpression: !6, upperBound: !34, upperBoundExpression: !7)
!42 = !{ !41 }
!43 = !DIFortranArrayType(tag: DW_TAG_array_type, size: 32, align: 32, baseType: !9, elements: !42)
!44 = distinct !DIGlobalVariable(scope: !18, name: "sarr", file: !2, type: !43, isLocal: true, isDefinition: true)
!45 = !DIGlobalVariableExpression(var: !44, expr: !21)
!46 = !DILocation(line: 6, column: 1, scope: !18)
