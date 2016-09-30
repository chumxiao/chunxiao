函数
func_name():
     print 'hello'
func_name()
global   全局变量


def func_name():
	global a
	print a
	a = 1
a = 100
func_name()
print a    (先打印100，后打印1)

赋值函数
def func_name(arg):
	print arg
func_name('hello') 

def func_name(arg,arg1,arg2,arg3):
	print arg,arg1,arg2,arg3
func_name(arg1='hello',arg3=1,arg2=2,arg=3) 


def func_name(arg1,arg2,arg3,arg=200):  (arg=200一定要写在后面)
 22         print arg,arg1,arg2,arg3
func_name(2,3,4) 

def func_name(*arg):  (赋多个值  *)
	print arg
func_name(1,2,3,4)

def func_name(*arg):
	print arg
li = [3,4,5,6]
func_name(li)  (答案带逗号)
([3,4,5,6],)  有逗号代表只赋给了一，不带逗号的多个赋值
func_name(*li)


def func_name(arg1,arg2,arg3,arg=None,arg4=None)
	print arg,arg1,arg2,arg3
func_name(1,2,3)


def func_name(name,age,phone):
	print name,age,phone
name = 'tom'
age = 100
phone = 11111
func_name(name,age,phone)


def func_name(name,age,phone):
	func2()
	print name,age,phone
def func():
	print 'hello'
name = 'tom'
age = 100
phone = 1111
func_name(name,age,phone)

字典
def func_name(x,o,y):
	dic = { 
		'+':x+y,
		'-':x+y,
		'*':x+y,
		'/':x+y
		}
	print dic['+'] 把+变成o  再执行看变化

func_name(1,'+',2)


def func_name(*arg)：
	host = arg[0]
	port = arg[1]
	username = arg[2]
	passwd = arg[3]
	db = None  (赋值db)
	if len(arg) == 5
		db = arg[4]
func_name('172.25.37.5',3306,'root','12345')

  def func_name(**kwarg):
           print kwarg.has_key('db')
                   
   func_name(name='tom',age='100',phone='11111')    返回false
因为没有db



   

		





































