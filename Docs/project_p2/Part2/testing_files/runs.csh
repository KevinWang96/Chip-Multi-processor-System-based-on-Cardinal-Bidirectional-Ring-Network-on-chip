#!/bin/csh -f

set cur_dir = `pwd`
echo $cur_dir
set myid = `whoami`
echo $myid


set tests = ${cur_dir}/test_cases

# Remove log files
rm -f ${myid}.txt ${myid}.diff


make init
make clean
make 

@ num = 0
## Running total of 40 tests (0-39)
while ( $num < 40 )
	if ($num == 0) then
		cp ${tests}/dmem_0.0.fill cmp_test.dmem.0.fill
		cp ${tests}/dmem_0.1.fill cmp_test.dmem.1.fill
		cp ${tests}/dmem_0.2.fill cmp_test.dmem.2.fill
		cp ${tests}/dmem_0.3.fill cmp_test.dmem.3.fill
		
		cp ${tests}/imem_0.0.fill cmp_test.imem.0.fill
		cp ${tests}/imem_0.1.fill cmp_test.imem.1.fill
		cp ${tests}/imem_0.2.fill cmp_test.imem.2.fill
		cp ${tests}/imem_0.3.fill cmp_test.imem.3.fill
	else 
		cp ${tests}/dmem.fill cmp_test.dmem.0.fill
		cp ${tests}/dmem.fill cmp_test.dmem.1.fill
		cp ${tests}/dmem.fill cmp_test.dmem.2.fill
		cp ${tests}/dmem.fill cmp_test.dmem.3.fill
		
		cp ${tests}/imem_${num}.fill cmp_test.imem.0.fill
		cp ${tests}/imem_${num}.fill cmp_test.imem.1.fill
		cp ${tests}/imem_${num}.fill cmp_test.imem.2.fill
		cp ${tests}/imem_${num}.fill cmp_test.imem.3.fill
	endif
	
	echo "" >> ${myid}.txt
	echo "Running Test # ${num} " >> ${myid}.txt
	echo "Running Test # ${num} " >> ${myid}.diff
	echo "Running Test # ${num} "
	
	# Run the test
	make run >> ${myid}.txt
	
	if ($num == 0) then
		echo "diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.0.dump cmp_test.dmem0.dump" >> ${myid}.diff
		diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.0.dump cmp_test.dmem0.dump >> ${myid}.diff
		diff --ignore-all-space ${tests}/expected_dmem_${num}.0.dump cmp_test.dmem0.dump >> ${myid}.diff
		
		echo "diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.1.dump cmp_test.dmem1.dump" >> ${myid}.diff
		diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.1.dump cmp_test.dmem1.dump >> ${myid}.diff
		diff --ignore-all-space ${tests}/expected_dmem_${num}.1.dump cmp_test.dmem1.dump >> ${myid}.diff
		
		echo "diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.2.dump cmp_test.dmem2.dump" >> ${myid}.diff
		diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.2.dump cmp_test.dmem2.dump >> ${myid}.diff
		diff --ignore-all-space ${tests}/expected_dmem_${num}.2.dump cmp_test.dmem2.dump >> ${myid}.diff
		
		echo "diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.3.dump cmp_test.dmem3.dump" >> ${myid}.diff
		diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.3.dump cmp_test.dmem3.dump >> ${myid}.diff
		diff --ignore-all-space ${tests}/expected_dmem_${num}.3.dump cmp_test.dmem3.dump >> ${myid}.diff
	else 
		echo "diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem0.dump" >> ${myid}.diff
		diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem0.dump >> ${myid}.diff
		diff --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem0.dump >> ${myid}.diff

		echo "diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem1.dump" >> ${myid}.diff
		diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem1.dump >> ${myid}.diff
		diff --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem1.dump >> ${myid}.diff

		echo "diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem2.dump" >> ${myid}.diff
		diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem2.dump >> ${myid}.diff
		diff --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem2.dump >> ${myid}.diff

		echo "diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem3.dump" >> ${myid}.diff
		diff --brief --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem3.dump >> ${myid}.diff
		diff --ignore-all-space ${tests}/expected_dmem_${num}.dump cmp_test.dmem3.dump >> ${myid}.diff
	endif

	echo " " >> ${myid}.diff
	echo " " >> ${myid}.diff

	@ num = $num + 1
end

## End of testing
# Here are the results file
ls ${myid}*
