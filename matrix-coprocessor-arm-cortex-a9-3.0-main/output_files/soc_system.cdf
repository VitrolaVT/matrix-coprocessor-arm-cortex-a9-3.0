/* Quartus Prime Version 23.1std.0 Build 991 11/28/2023 SC Lite Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Ign)
		Device PartName(SOCVHPS) MfrSpec(OpMask(0));
	P ActionCode(Cfg)
		Device PartName(5CSEMA5F31) Path("/media/aluno/VIC-DRIVE/Projeto_PBL3_RICTOR/matrix-coprocessor-arm-cortex-a9-2.0 - PBL2_FINAL_BLESSED_RICTOR/output_files/") File("soc_system.sof") MfrSpec(OpMask(1));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
