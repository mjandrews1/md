// Package: md
// File:    src/opcode.d
// Summary: MUMPS Opcode Definitions
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module opcode;

/// MUMPS Opcodes
enum Opcode : ubyte {
    ENDLIN = 0,     // End of line
    OPHALT = 1,     // Halt instruction
    OPERROR = 2,    // Error
    OPNOT = 3,      // Boolean NOT
    OPENDC = 4,     // End of command
    JMP0 = 5,       // Jump if false
    OPIFN = 6,      // No arg if
    OPIFA = 7,      // If (check stack)
    OPIFI = 8,      // If indirect
    OPELSE = 9,     // Else
    OPADD = 10,     // Add top two on stack
    OPSUB = 11,     // Subtract
    OPMUL = 12,     // Multiply
    OPDIV = 13,     // Divide
    OPINT = 14,     // Integer divide
    OPMOD = 15,     // Modulus
    OPPOW = 16,     // Power
    OPCAT = 17,     // Concatenate
    OPPLUS = 18,    // Unary plus
    OPMINUS = 19,   // Unary minus
    OPEQL = 20,     // Equal
    OPLES = 21,     // Less than
    OPGTR = 22,     // Greater than
    OPAND = 23,     // And
    OPIOR = 24,     // Inclusive or
    OPCON = 25,     // Contains
    OPFOL = 26,     // Follows
    OPSAF = 27,     // Sorts after
    OPPAT = 28,     // Pattern match
    OPHANG = 29,    // Hang
    OPNEQL = 30,    // Not equal
    OPNLES = 31,    // Not less than
    OPNGTR = 32,    // Not greater than
    OPNAND = 33,    // Not and
    OPNIOR = 34,    // Not or
    OPNCON = 35,    // Not contains
    OPNFOL = 36,    // Not follows
    OPNSAF = 37,    // Not sorts after
    OPNPAT = 38,    // Not pattern match
    CMSET = 41,     // Set
    CMSETE = 42,    // Set $EXTRACT
    CMSETP = 43,    // Set $PIECE
    OPNAKED = 44,   // Set NAKED
    CMFLUSH = 45,   // Flush inputs
    CMREADS = 46,   // Read star
    CMREADST = 47,  // Read star with timeout
    CMREAD = 48,    // Read variable
    CMREADT = 49,   // Read variable with timeout
    CMREADC = 50,   // Read variable count
    CMREADCT = 51,  // Read variable count with timeout
    CMWRTST = 52,   // Write star
    CMWRTNL = 53,   // Write newline
    CMWRTFF = 54,   // Write form feed
    CMWRTAB = 55,   // Write tab
    CMWRTEX = 56,   // Write expression
    CMUSE = 57,     // Use
    CMOPEN = 58,    // Open
    CMCLOSE = 59,   // Close
    OPSTR = 60,     // String
    OPVAR = 61,     // Variable
    OPMVAR = 62,    // MUMPS variable
    OPMVARN = 63,   // MUMPS variable (null OK)
    OPMVARF = 64,   // MUMPS variable full size
    INDEVAL = 65,   // Indirect eval
    INDMVAR = 66,   // Indirect mvar
    INDMVARN = 67,  // Indirect mvar (null OK)
    INDMVARF = 68,  // Indirect mvar full size
    OPBRK0 = 70,    // Break argless
    OPBRKN = 71,    // Break with args
    CMDO = 72,      // Do
    CMDOARG = 73,   // Do with args
    CMFOR0 = 74,    // For argless
    CMFOR1 = 75,    // For with args
    CMFOR2 = 76,    // For with condition
    CMGOTO = 77,    // Goto
    CMIF = 78,      // If
    CMELSE = 79,    // Else
    CMNEW = 80,     // New
    CMNEWB = 81,    // New with args
    CMQUIT = 82,    // Quit
    CMQUITA = 83,   // Quit with args
    CMRET = 84,     // Return
    CMKILL = 85,    // Kill
    CMKILLA = 86,   // Kill with args
    CMXECUTE = 87,  // Xecute
    CMXECE = 88,    // Xecute with args
    CMJOB = 89,     // Job
    CMJOB0 = 90,    // Job argless
    CMLOCK = 91,    // Lock
    CMLOCK0 = 92,   // Lock argless
    CMUNLOCK = 93,  // Unlock
    CMVIEW = 94,    // View
    CMQUITR = 95,   // Quit from routine
    CMDOREF = 96,   // Do reference
    CMDOREFARG = 97, // Do reference with args
    CMSETE2 = 98,   // Set $EXTRACT 2 args
    CMSETE3 = 99,   // Set $EXTRACT 3 args
    CMSETP2 = 100,  // Set $PIECE 2 args
    CMSETP3 = 101,  // Set $PIECE 3 args
    CMSETP4 = 102,  // Set $PIECE 4 args
}

/// Get opcode name
string opcodeName(Opcode op) {
    final switch (op) {
        case Opcode.ENDLIN: return "ENDLIN";
        case Opcode.OPHALT: return "OPHALT";
        case Opcode.OPERROR: return "OPERROR";
        case Opcode.OPNOT: return "OPNOT";
        case Opcode.OPENDC: return "OPENDC";
        case Opcode.JMP0: return "JMP0";
        case Opcode.OPIFN: return "OPIFN";
        case Opcode.OPIFA: return "OPIFA";
        case Opcode.OPIFI: return "OPIFI";
        case Opcode.OPELSE: return "OPELSE";
        case Opcode.OPADD: return "OPADD";
        case Opcode.OPSUB: return "OPSUB";
        case Opcode.OPMUL: return "OPMUL";
        case Opcode.OPDIV: return "OPDIV";
        case Opcode.OPINT: return "OPINT";
        case Opcode.OPMOD: return "OPMOD";
        case Opcode.OPPOW: return "OPPOW";
        case Opcode.OPCAT: return "OPCAT";
        case Opcode.OPPLUS: return "OPPLUS";
        case Opcode.OPMINUS: return "OPMINUS";
        case Opcode.OPEQL: return "OPEQL";
        case Opcode.OPLES: return "OPLES";
        case Opcode.OPGTR: return "OPGTR";
        case Opcode.OPAND: return "OPAND";
        case Opcode.OPIOR: return "OPIOR";
        case Opcode.OPCON: return "OPCON";
        case Opcode.OPFOL: return "OPFOL";
        case Opcode.OPSAF: return "OPSAF";
        case Opcode.OPPAT: return "OPPAT";
        case Opcode.OPHANG: return "OPHANG";
        case Opcode.OPNEQL: return "OPNEQL";
        case Opcode.OPNLES: return "OPNLES";
        case Opcode.OPNGTR: return "OPNGTR";
        case Opcode.OPNAND: return "OPNAND";
        case Opcode.OPNIOR: return "OPNIOR";
        case Opcode.OPNCON: return "OPNCON";
        case Opcode.OPNFOL: return "OPNFOL";
        case Opcode.OPNSAF: return "OPNSAF";
        case Opcode.OPNPAT: return "OPNPAT";
        case Opcode.CMSET: return "CMSET";
        case Opcode.CMSETE: return "CMSETE";
        case Opcode.CMSETP: return "CMSETP";
        case Opcode.OPNAKED: return "OPNAKED";
        case Opcode.CMFLUSH: return "CMFLUSH";
        case Opcode.CMREADS: return "CMREADS";
        case Opcode.CMREADST: return "CMREADST";
        case Opcode.CMREAD: return "CMREAD";
        case Opcode.CMREADT: return "CMREADT";
        case Opcode.CMREADC: return "CMREADC";
        case Opcode.CMREADCT: return "CMREADCT";
        case Opcode.CMWRTST: return "CMWRTST";
        case Opcode.CMWRTNL: return "CMWRTNL";
        case Opcode.CMWRTFF: return "CMWRTFF";
        case Opcode.CMWRTAB: return "CMWRTAB";
        case Opcode.CMWRTEX: return "CMWRTEX";
        case Opcode.CMUSE: return "CMUSE";
        case Opcode.CMOPEN: return "CMOPEN";
        case Opcode.CMCLOSE: return "CMCLOSE";
        case Opcode.OPSTR: return "OPSTR";
        case Opcode.OPVAR: return "OPVAR";
        case Opcode.OPMVAR: return "OPMVAR";
        case Opcode.OPMVARN: return "OPMVARN";
        case Opcode.OPMVARF: return "OPMVARF";
        case Opcode.INDEVAL: return "INDEVAL";
        case Opcode.INDMVAR: return "INDMVAR";
        case Opcode.INDMVARN: return "INDMVARN";
        case Opcode.INDMVARF: return "INDMVARF";
        case Opcode.OPBRK0: return "OPBRK0";
        case Opcode.OPBRKN: return "OPBRKN";
        case Opcode.CMDO: return "CMDO";
        case Opcode.CMDOARG: return "CMDOARG";
        case Opcode.CMFOR0: return "CMFOR0";
        case Opcode.CMFOR1: return "CMFOR1";
        case Opcode.CMFOR2: return "CMFOR2";
        case Opcode.CMGOTO: return "CMGOTO";
        case Opcode.CMIF: return "CMIF";
        case Opcode.CMELSE: return "CMELSE";
        case Opcode.CMNEW: return "CMNEW";
        case Opcode.CMNEWB: return "CMNEWB";
        case Opcode.CMQUIT: return "CMQUIT";
        case Opcode.CMQUITA: return "CMQUITA";
        case Opcode.CMRET: return "CMRET";
        case Opcode.CMKILL: return "CMKILL";
        case Opcode.CMKILLA: return "CMKILLA";
        case Opcode.CMXECUTE: return "CMXECUTE";
        case Opcode.CMXECE: return "CMXECE";
        case Opcode.CMJOB: return "CMJOB";
        case Opcode.CMJOB0: return "CMJOB0";
        case Opcode.CMLOCK: return "CMLOCK";
        case Opcode.CMLOCK0: return "CMLOCK0";
        case Opcode.CMUNLOCK: return "CMUNLOCK";
        case Opcode.CMVIEW: return "CMVIEW";
        case Opcode.CMQUITR: return "CMQUITR";
        case Opcode.CMDOREF: return "CMDOREF";
        case Opcode.CMDOREFARG: return "CMDOREFARG";
        case Opcode.CMSETE2: return "CMSETE2";
        case Opcode.CMSETE3: return "CMSETE3";
        case Opcode.CMSETP2: return "CMSETP2";
        case Opcode.CMSETP3: return "CMSETP3";
        case Opcode.CMSETP4: return "CMSETP4";
    }
}

unittest {
    assert(opcodeName(Opcode.OPADD) == "OPADD");
    assert(opcodeName(Opcode.CMSET) == "CMSET");
    assert(opcodeName(Opcode.OPHALT) == "OPHALT");
}
