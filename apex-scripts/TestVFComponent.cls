Approval_VF_Controller VF = new Approval_VF_Controller();
opportunity Opp = new Opportunity();
Opp.ID = '006O0000008lfq0';
VF.oppRecord = Opp;
System.debug(loggingLevel.Error, '*** Current Approver: ' + VF.getAssignedApprover());
System.debug(loggingLevel.Error, '*** ApproversForCurrentGate: ' + VF.getApproversForCurrentGate());