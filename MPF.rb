class Analyzer

def initialize(dataFile)
	@controlSet=dataFile
	@controlSet=@controlSet.split(' ')
	removeNoise(@controlSet)
	puts "Enter the size of the training sample as a percentage:"
	@percent=gets.chomp
	#@percent=20
	#@controlSet=randomize(@controlSet)
	@trainingSet=createTrainingSet(@percent,@controlSet)
	@controlSet=createControlSet(@percent,@controlSet)
end
def createControlSet(num, data)
	num=num.to_f
	num=num/100
	tmp=data.length*num
	return data.drop(tmp)
end
def createTrainingSet(num,data)
	num=num.to_f
	num=num/100
	tmp=data.length*num
	return data.take(tmp)
end
def removeNoise(data)
	data.delete_if {|x| x=~/[\d,]+\?[\d,]+/}
end
def randomize(data)
	data.sort_by {rand}
end
def getTrainingSet()
	return @trainingSet
end
def getControlSet()
	return @controlSet
end
end

class Classificator
	def initialize(dataSet, controlSet)
		@data=dataSet
		@controlData=controlSet
		@dataDistance=Array.new()
		@controlDistance=Array.new()
		@arrCharge=[]
		#show('0')
	end
	def show(num)
		summ=0.0
		middle=0.0
		counter=0
		@data.each do |x|
			tmp=x.slice(11,1)			
			if tmp.eql? num
				temp=x.slice(9,1)
				temp=temp.to_i
				summ=summ+temp
				counter+=1
				#puts x
			end
		end
		puts middle=summ/counter
	end
	def kFunction(num)
		k=0.0
		return k=1/(num+1)
	end
	def distance(x)
			summ=0.0
			temp=x.slice(0,1)
			temp=temp.to_f
			summ=summ+temp
			temp=x.slice(2,2)
			temp=temp.to_f
			summ=summ+temp/100
			temp=x.slice(5,1)
			temp=temp.to_f
			summ=summ+temp/10
			temp=x.slice(7,1)
			temp=temp.to_f
			summ=summ+temp/10
	end
	def charge(x,k)
		i=0
		gamma=1
		@dataDistance.each do |y|
			if y[0]<x[0]
				i+=1
			end
		end
		if  i.eql? @dataDistance.length
			for j in @dataDistance.length-k..@dataDistance.length-1
				tmp=@dataDistance[j]
				if  !(tmp[1].eql? x[1])
					gamma+=1
				end
			end
		elsif i.eql? 0
			for j in 0..k
				tmp=@dataDistance[j]
				if  !(tmp[1].eql? x[1])
					gamma+=1
				end
			end
		elsif (i>0)&&(i<@dataDistance.length)
			left=i-1
			right=i
			tmp=@dataDistance[i]
			for j in 0...k
				if (left>0)&&(right<@dataDistance.length)
					tmpL=@dataDistance[left]
					tmpR=@dataDistance[right]
					lDif=tmp[0]-tmpL[0]
					rDif=tmp[0]-tmpR[0]
					lDif=lDif.abs
					rDif=rDif.abs
					if lDif<=rDif
						if  !(tmpL[1].eql? x[1])
							gamma+=1
						end
						left-=1
					else
						if  !(tmpR[1].eql? x[1])
							gamma+=1
						end
						right+=1
					end
				elsif (left<0)
					tmpR=@dataDistance[right]
					if  !(tmpR[1].eql? x[1])
						gamma+=1
					end
					right+=1
				elsif (right==@dataDistance.length)
					tmpL=@dataDistance[left]
					if  !(tmpL[1].eql? x[1])
						gamma+=1
					end
					left-=1
				end
			end
		end
		return gamma
	end
	def widthOfPotential(num)
		return num/5
	end
	def neighbors(k,val)
		i=0
		malignant=0.0
		benign=0.0
		@dataDistance.each do |x|
			if x[0]<val
				i+=1
			end	
		end
		if  i.eql? @dataDistance.length
			for j in @dataDistance.length-k..@dataDistance.length-1
				tmp=@dataDistance[j]
				if  tmp[1].eql? 1
					malignant+=@arrCharge[j]*kFunction(tmp[0]/widthOfPotential(tmp[0]))
				elsif tmp[1].eql? 0
					benign+=@arrCharge[j]*kFunction(tmp[0]/widthOfPotential(tmp[0]))
				end
			end
		elsif i.eql? 0
			for j in 0..k
				tmp=@dataDistance[j]
				if  tmp[1].eql? 1
					malignant+=@arrCharge[j]*kFunction(tmp[0]/widthOfPotential(tmp[0]))
				elsif tmp[1].eql? 0
					benign+=@arrCharge[j]*kFunction(tmp[0]/widthOfPotential(tmp[0]))
				end
			end
		elsif (i>0)&&(i<@dataDistance.length)
			arr=[]
			ind=[]
			left=i-1
			right=i
			tmp=@dataDistance[i]
			for j in 0...k
				if (left>0)&&(right<@dataDistance.length)
					tmpL=@dataDistance[left]
					tmpR=@dataDistance[right]
					lDif=tmp[0]-tmpL[0]
					rDif=tmp[0]-tmpR[0]
					lDif=lDif.abs
					rDif=rDif.abs
					if lDif<=rDif
						arr=arr.push(tmpL)
						ind=ind.push(left)
						left-=1
					else
						arr=arr.push(tmpR)
						ind=ind.push(right)
						right+=1
					end
				elsif (left<0)
					tmpR=@dataDistance[right]
					arr=arr.push(tmpR)
					ind=ind.push(right)
					right+=1
				elsif (right==@dataDistance.length)
					tmpL=@dataDistance[left]
					arr=arr.push(tmpL)
					ind=ind.push(left)
					left-=1
				end
			end
			arr.each_with_index do |x,index|
				if x[1].eql? 1
					malignant+=@arrCharge[ind[index]]*kFunction(tmp[0]/widthOfPotential(tmp[0]))
				elsif x[1].eql? 0
					benign+=@arrCharge[ind[index]]*kFunction(tmp[0]/widthOfPotential(tmp[0]))
				end
			end
		end
		if malignant> benign
			return 1
		else
			return 0
		end
	end
	def mainFunction(knn)
		rightAnswers=0.0
		@data.each do |x|
			temp=x.slice(11,1)
			temp=temp.to_i
			tmp=[distance(x),temp]
			@dataDistance.push(tmp)
		end
		@dataDistance=@dataDistance.sort! { |x,y| x<=>y }
		arrCharge=[]
		@dataDistance.each do |x|
			arrCharge.push(charge(x,knn))
		end
		@arrCharge=arrCharge
		@controlData.each do |x|
			temp=distance(x)
			tmp=x.slice(11,1)
			tmp=tmp.to_i
			answer=neighbors(knn,temp)
			if tmp.eql? answer
				rightAnswers+=1
			end
		end
		percent=0.0
		percent=(rightAnswers/@controlData.length)*100
		return percent
	end
	def loo()
		inform=[]
		tmp=0.0
		i=@data.length-1
		for j in 2..i
			tmp=mainFunction(j)
			inform=inform.push(j,tmp)
			puts j
			puts tmp
			puts '*******************'
		end
	end
	def recomendation()
		int=@data.length
		rec=int*0.75
		puts "Recommended size of nearest neighbors:"
		puts rec.to_i
		return rec.to_i
	end
end
class Controller
def initialize(file)
	@dataFile=IO.read(file) 
	analyzer=Analyzer.new(@dataFile)
	classificator=Classificator.new(analyzer.getTrainingSet, analyzer.getControlSet)
	classificator.recomendation
	puts "Enter the number of nearest neighbors:"
	knn=gets.chomp
	knn=knn.to_i
	pr=classificator.mainFunction(knn)
	puts pr
	#classificator.loo
end
end
runing=Controller.new('data.txt')
STDIN.getc