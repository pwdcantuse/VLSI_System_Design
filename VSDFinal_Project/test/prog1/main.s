.data
test1: .word 16,2,4,16,4,10,12,2,14,8,4,14,6,4,2,10,12,6,10,2,14,14,6,8,16,8,16,6,12,10,8,123
test2: .word 470,405,225,197,126,122,56,33,-81,-275,-379,-409,-416,-496,-500
test3: .word 412,-474,443,171,-23,247,221,7,40,221,-90,61,-9,49,-80,-80,221,-379,-161,-397,-173,276,-197,221,-12,-145,101

TEST1_SIZE: .word 32
TEST2_SIZE: .word 15
TEST3_SIZE: .word 27


.text
.globl main
main:
	addi sp, sp, -4
	sw s0, 0(sp)
	la s0, _answer
	
##----------------------------------------------------------------------lab8
##將test1、2、3的data移到0x9000##
	la    t0,test1
	la    t1,TEST1_SIZE
    lw    t1,0(t1)
	mv    t2,t1
	la    t1,TEST2_SIZE
    lw    t1,0(t1)
	add   t2,t2,t1
	la    t1,TEST3_SIZE
    lw    t1,0(t1)
	add   t2,t2,t1             #t2:test1_size+test2_size+test3_size
	li    t1,0                 #t1=i=0
	li    t4,0x00009000
loop:
	bge   t1,t2,end_loop
	lw    t3,0(t0)
	sw    t3,0(t4)
	addi  t1,t1,1
    addi  t0,t0,4
	addi  t4,t4,4
	beq   x0,x0,loop
end_loop:	


##求test1、2、3的初始位置##
	
	
	li    t0,0x9000            ##t0:test1的初始位置
	
	
	la    t1,TEST1_SIZE
    lw    t1,0(t1)             ##t1:test1_size
	slli  t1,t1,2              ##t1=t1*4
	add   t2,t0,t1             ##t2:test2的初始位置
	
	
	la    t1,TEST2_SIZE
    lw    t1,0(t1)             ##t1:test2_size
	slli  t1,t1,2              ##t1=t1*4
	add   t3,t2,t1             ##t3:test3的初始位置
##----------------------------------------------------------------------lab8
	
	####callee saved 	
	addi 	sp,sp,-24
	sw	    s0,0(sp)
	sw	    s1,4(sp)   
	sw	    s2,8(sp)   
	sw	    s3,12(sp)  
	sw	    s4,16(sp)  
	sw	    s5,20(sp)
	
	

	####	
	mv    s0,t0				    #s0放test1的初始位置地址
	la    s1,TEST1_SIZE         #s1放TEST1_SIZE的地址
	lw    s1,0(s1)              #把s1地址存的東西(陣列長度)放在s1
	
	mv    s2,t2				    #s2放test1的初始位置地址
	la    s3,TEST2_SIZE         #s3放TEST1_SIZE的地址
	lw    s3,0(s3)              #把s3地址存的東西(陣列長度)放在s1
	
	mv    s4,t3				    #s4放test1的初始位置地址
	la    s5,TEST3_SIZE         #s5放TEST1_SIZE的地址
	lw    s5,0(s5)              #把s5地址存的東西(陣列長度)放在s1

	####caller saved
	addi   sp,sp,-4				#sp向下4byte
	sw     ra,0(sp)       		#Caller saved:這時ra=-1
	
	############################# test1 #############################
	####給參數值
	mv    a0,s0				    # a0 =s0 = test1的初始位置
	mv    a1,x0				    # a1 =x0 = start
	addi  a2,s1,-1              # a2 = TEST1_SIZE-1 = end
	####呼叫function : mergesort
	jal   ra, mergesort     	#ra = 下一行
	
	############################# test2 #############################
	####給參數值
	mv    a0,s2				    # a0 =s2 = test2的初始位置
	mv    a1,x0				    # a1 =x0 = start
	addi  a2,s3,-1              # a2 = TEST1_SIZE-1 = end
	####呼叫function : mergesort
	jal   ra, mergesort     	#ra = 下一行
	
	############################# test3 #############################
	####給參數值
	mv    a0,s4				    # a0 =s4 = test3的初始位置
	mv    a1,x0				    # a1 =x0 = start
	addi  a2,s5,-1              # a2 = TEST1_SIZE-1 = end
	####呼叫function : mergesort
	jal   ra, mergesort     	#ra = 下一行	
	#################################################################


    ####Caller saved:restore	
    lw    ra, 0(sp)             #Caller saved:拿回一開始呼叫前存的ra=-1
    addi  sp, sp, 4             #釋放stack空間	
	
	####callee saved:restore	
	
	lw	    s0,0(sp)
	lw	    s1,4(sp)   
	lw	    s2,8(sp)   
	lw	    s3,12(sp)  
	lw	    s4,16(sp)  
	lw	    s5,20(sp)
	addi 	sp,sp,24
	
    ret                         #jalr  x0, ra, 0

############    mergesort    ##############
# t0 : test的初始位置地址
# t1 : start
# t2 : end
# t3 : mid = (start+end)/2

mergesort:
	
	####轉移參數	
	mv    t0, a0	    # t0 : test的初始位置地址
	mv	  t1, a1	    # t1 : start
	mv	  t2, a2	    # t2 : end
	
	#### if(start<end) => if(start>=end) , 跳去mergesort_end
	bge	t1, t2, mergesort_end

	####求mid，放在t3
	add    t3,t2,t1     #t3 = t1+t2 = start+end
	srli   t3,t3,1      #t3 = t3/2 = (start+end)/2 = mid
	
	
	#/////////////////////////左邊 : mergesort(arr, start, mid);
	####Caller saved : ra ,test的初始位置地址(t0), start(t1), end(t2), mid(t3)
	
	addi 	sp,sp,-20
	sw	    ra,0(sp)
	sw	    t0,4(sp)     #test的初始位置地址
	sw	    t1,8(sp)     #start
	sw	    t2,12(sp)    #end
	sw	    t3,16(sp)    #mid
	
	####給參數值
	mv 	  a0, t0	    # a0 = t0 = test的初始位置地址
	mv 	  a1, t1	    # a1 = t1 = start
	mv 	  a2, t3	    # a2 = t3 = mid
	
	####Call left mergesort
	jal	  ra, mergesort

	####Caller saved : restore
	lw	    ra,0(sp)
	lw	    t0,4(sp)     #test的初始位置地址
	lw	    t1,8(sp)     #start
	lw	    t2,12(sp)    #end
	lw	    t3,16(sp)    #mid
	addi 	sp,sp,20


	#/////////////////////////右邊 : mergesort(arr, mid+1, end);
	####Caller saved : ra ,test的初始位置地址(t0), start(t1), end(t2), mid(t3)
	
	addi 	sp,sp,-20
	sw	    ra,0(sp)
	sw	    t0,4(sp)     #test的初始位置地址
	sw	    t1,8(sp)     #start                             
	sw	    t2,12(sp)    #end
	sw	    t3,16(sp)    #mid
	
	####給參數值
	mv	    a0,t0	     #a0 = t0 = test的初始位置地址
	addi    t3,t3,1	     #t3 = mid+1 
	mv	    a1,t3        #a1 = t3 = mid+1
	mv	    a2,t2        #a2 = t2 = end
	
	####Call right mergesort
	jal	    ra, mergesort
	
	####Caller saved : restore
	lw	    ra,0(sp)
	lw	    t0,4(sp)     #test的初始位置地址
	lw	    t1,8(sp)     #start
	lw	    t2,12(sp)    #end
	lw	    t3,16(sp)    #mid
	addi 	sp,sp,20	
	
	#///////////////////////// 最後 : merge(arr, start, mid, end);
	addi 	sp,sp,-20
	sw	    ra,0(sp)
	sw	    t0,4(sp)     #test的初始位置地址
	sw	    t1,8(sp)     #start                             
	sw	    t2,12(sp)    #end
	sw	    t3,16(sp)    #mid
	
	####給參數值
	mv	    a0,t0	     #a0 = t0 = test的初始位置地址
	mv      a1,t1        #a1 = t1 = start
	mv	    a2,t3        #a2 = t3 = mid
	mv	    a3,t2        #a3 = t2 = end
	
    ####Call  merge
	jal	    ra, merge
	
	####Caller saved : restore
	lw	    ra,0(sp)
	lw	    t0,4(sp)     #test的初始位置地址
	lw	    t1,8(sp)     #start
	lw	    t2,12(sp)    #end
	lw	    t3,16(sp)    #mid
	addi 	sp,sp,20	

mergesort_end:	
	jalr	x0, ra, 0
	
	
	
############    merge    ##############
# s0 : temp_size
# s1 : temp的初始位置地址
# s2 : left_index
# s3 : right_index
# s4 : left_max
# s5 : right_max
# s6 : arr_index
# s7 : temp_size*4

merge:
	####callee saved
	addi 	sp,sp,-32
	sw	    s0,0(sp)
	sw	    s1,4(sp)     
	sw	    s2,8(sp)                   
	sw	    s3,12(sp)    
	sw	    s4,16(sp) 
	sw	    s5,20(sp)
	sw	    s6,24(sp)
	sw	    s7,28(sp)
	
	####轉移參數
	mv    t0, a0	    # t0 : test的初始位置地址
	mv	  t1, a1	    # t1 : start
	mv	  t2, a2	    # t2 : mid
	mv	  t3, a3	    # t3 : end
	
	####int temp_size = end - start + 1;
	add   t4,t3,t1      #t4 = t3-t1 = end-start 
	addi  s0,t4,1       #s0 = end-start+1 = temp_size
	
	####創造長度為temp_size的array(temp)放在stack
	slli  t4,s0,2       #t4 = temp_size*4
	sub   sp,sp,t4      #sp向下移temp_size*4
	mv    s7,t4         #把temp_size*4存在s7
	mv    s1,sp         #s1存temp的初始位置地址
	
	
	################# for loop #################
	li    t4,0          #int i = 0;
	
for_loop:
 
    bge   t4,s0,end_for_loop    #if(i>=temp_size) go to end_for_loop
	
	## boby
	
	#取得arr[i+start]的值
	add   t5,t4,t1      #t5=i+start
	slli  t5,t5,2       #t5=t5*4
	add   t5,t5,t0      #t5=arr[i+start]的地址	
	lw    t5,0(t5)      #t5=arr[i+start]的值
	
	#將arr[i+start]的值放在temp[i]
	slli  t6,t4,2       #t6 = i*4
	add   t6,t6,s1      #t6 = t6+s1 = i*4+temp的初始位置地址 = temp[i]的地址
	sw    t5,0(t6)      #將arr[i+start]的值放在temp[i]
	
	## i++
	addi  t4,t4,1
	
	beq   x0,x0,for_loop
	
end_for_loop:
	################# for loop #################
	
	
	####初始化
	li    s2,0         #int left_index = 0;
	sub   t4,t2,t1     #t4 = mid-start
	addi  s3,t4,1      #int right_index = mid-start+1;
	sub   s4,t2,t1     #int left_max = mid-start;
	sub   s5,t3,t1     #int right_max = end-start;
	mv    s6,t1        #int arr_index = start;
	
	
######################## first while loop #############################
	
first_while:
	
    bgt   s2,s4,first_while_end  #if left_index > left_max, go to first_while_end
	bgt   s3,s5,first_while_end  #if right_index > right_max, go to first_while_end
	
	## boby ##
	
	slli  t4,s2,2      #t4=left_index*4
	add   t4,t4,s1     #t4=left_index*4+temp的初始位置地址
	lw    t4,0(t4)     #t4=temp[left_index]
	
	slli  t5,s3,2      #t5=right_index*4
	add   t5,t5,s1     #t5=right_index*4+temp的初始位置地址
	lw    t5,0(t5)     #t5=temp[right_index]
	
	blt   t5,t4,else_1 #if(temp[left_index] > temp[right_index]) go to else_1
	
if_1:
	slli  t6,s6,2      #t6=arr_index*4
	add   t6,t6,t0     #t6=arr_index*4+arr的初始位置地址
	sw    t4,0(t6)     #arr[arr_index] = temp[left_index];
	
	addi  s6,s6,1      #arr_index++
	addi  s2,s2,1      #left_index++
	
	beq   x0,x0,end_1  
	
else_1:
	slli  t6,s6,2      #t6=arr_index*4
	add   t6,t6,t0     #t6=arr_index*4+arr的初始位置地址
	sw    t5,0(t6)     #arr[arr_index] = temp[right_index];
	
	addi  s6,s6,1      #arr_index++
	addi  s3,s3,1      #right_index++

end_1:
	beq   x0,x0,first_while
	
	## boby ##
	
first_while_end:       #first_while條件式不符合，跳到這裡


######################## second while loop #############################
	
second_while:
	
    blt   s4,s2,second_while_end   #if left_index > left_max, go to second_while_end

	## boby ##
	
	slli  t4,s2,2      #t4=left_index*4
	add   t4,t4,s1     #t4=left_index*4+temp的初始位置地址
	lw    t4,0(t4)     #t4=temp[left_index]
	
	
	slli  t6,s6,2      #t6=arr_index*4
	add   t6,t6,t0     #t6=arr_index*4+arr的初始位置地址
	sw    t4,0(t6)     #arr[arr_index] = temp[left_index];
	
	addi  s6,s6,1      #arr_index++
	addi  s2,s2,1      #left_index++
	
	## boby ##
	
	beq   x0,x0,second_while
	
second_while_end:       #second_while條件式不符合，跳到這裡	
	
	
######################## third while loop #############################
	
third_while:
	
	blt   s5,s3,third_while_end   #if right_index > right_max, go to third_while_end
	
	## boby ##
		
	slli  t5,s3,2      #t5=right_index*4
	add   t5,t5,s1     #t5=right_index*4+temp的初始位置地址
	lw    t5,0(t5)     #t5=temp[right_index]
	
	slli  t6,s6,2      #t6=arr_index*4
	add   t6,t6,t0     #t6=arr_index*4+arr的初始位置地址
	sw    t5,0(t6)     #arr[arr_index] = temp[right_index];
	
	addi  s6,s6,1      #arr_index++
	addi  s3,s3,1      #right_index++

    ## boby ##
	
	beq   x0,x0,third_while
	
third_while_end:       #third_while條件式不符合，跳到這裡	
	
#########################################################################
	
	
	add    sp,sp,s7    #將temp_size*4加回來
	
	####callee saved:restore
	lw	    s0,0(sp)
	lw	    s1,4(sp)     
	lw	    s2,8(sp)                   
	lw	    s3,12(sp)    
	lw	    s4,16(sp) 
	lw	    s5,20(sp)
	lw	    s6,24(sp)
	lw      s7,28(sp)
	addi 	sp,sp,32
	
	ret

main_exit:

  lw s0, 0(sp)
  addi sp, sp, 4
  ret