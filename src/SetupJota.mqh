//+------------------------------------------------------------------+
//|                                   Copyright 2018, Erlon F. Souza |
//|                                       https://github.com/erlonfs |
//+------------------------------------------------------------------+

#property copyright "Copyright 2018, Erlon F. Souza"
#property link      "https://github.com/erlonfs"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <BadRobot.Framework\BadRobot.mqh>

class SetupJota : public BadRobot
{
      private:
   
      MqlRates _rates[];
      bool _wait;
      double _maxima;
      double _minima;
      
		//Indicadores
		int _eMALongPeriod;
		int _eMALongHandle;
		double _eMALongValues[];
		int _eMAShortPeriod;
		int _eMAShortHandle;
		double _eMAShortValues[];
		
		bool GetBuffers() {
			
			ZeroMemory(_eMALongValues);
			ZeroMemory(_eMAShortValues);
			ZeroMemory(_rates);
	
			ArraySetAsSeries(_eMALongValues, true);
			ArraySetAsSeries(_eMAShortValues, true);
			ArraySetAsSeries(_rates, true);
	
			int copiedMALongBuffer = CopyBuffer(_eMALongHandle, 0, 0, 10, _eMALongValues);
			int copiedMAShortBuffer = CopyBuffer(_eMAShortHandle, 0, 0, 10, _eMAShortValues);
			int copiedRates = CopyRates(GetSymbol(), GetPeriod(), 0, 10, _rates);
	
			return copiedRates > 0 && copiedMALongBuffer > 0 && copiedMAShortBuffer > 0;
	
		}
		
		bool Find(){
			return FindBuy() || FindSell();		
		}		
		
		bool FindBuy(){
				
			bool hasCondition = true;
			
			for(int i = 0; i < ArraySize(_rates); i++){
				
				if(_rates[i].low < _eMALongValues[i]){
					hasCondition = false;
					break;
				}
							
			}
			
			if(!hasCondition) return false;
			
			hasCondition = hasCondition && _rates[0].low > _eMALongValues[0];
			hasCondition = hasCondition && _rates[0].high < _eMALongValues[0] + 80; //Tolerancia
			hasCondition = hasCondition && _rates[0].high > _eMAShortValues[0]; //Fechamento acima da media curta
			
			_maxima = _rates[0].high;
			
			return hasCondition;
		
		} 
		
		bool FindSell(){
			
			bool hasCondition = true;
			
			for(int i = 0; i < ArraySize(_rates); i++){
				
				if(_rates[i].high > _eMALongValues[i]){
					hasCondition = false;
					break;
				}
							
			}
			
			if(!hasCondition) return false;
			
			hasCondition = hasCondition && _rates[0].high < _eMALongValues[0];
			hasCondition = hasCondition && _rates[0].low < _eMALongValues[0] - 80; //Tolerancia
			hasCondition = hasCondition && _rates[0].low < _eMAShortValues[0]; //Fechamento abaixo da media curta
			
			_minima = _rates[0].low;
			
			return hasCondition;
			
			
		}  
   
		public:
		
		void SetEMALongPeriod(int ema) {
			_eMALongPeriod = ema;
		};
		
		void SetEMAShortPeriod(int ema) {
			_eMAShortPeriod = ema;
		};            
      
      void Load()
   	{
			_eMALongHandle = iMA(GetSymbol(), GetPeriod(), _eMALongPeriod, 0, MODE_EMA, PRICE_CLOSE);
			_eMAShortHandle = iMA(GetSymbol(), GetPeriod(), _eMAShortPeriod, 0, MODE_EMA, PRICE_CLOSE);
			
			if (_eMALongHandle < 0 || _eMAShortHandle < 0) {
				Alert("Erro ao criar indicadores: erro ", GetLastError(), "!");
			}   	
   	};
   
   	void Execute() {
   	
			if(!BadRobot::ExecuteBase()) return;
			
			if(GetBuffers()){ 
			
				if(_wait || Find()){	   		   
				
	   		      _wait = true;
	   		      
						if(GetPrice().last > _eMALongValues[0]){
						
							if(GetPrice().last < _eMAShortValues[0]) return;
      		         		      		   
	      		      double _entrada = _maxima + GetSpread();
	         			double _auxStopGain = NormalizeDouble((_entrada + GetStopGain()), _Digits);
	         			double _auxStopLoss = NormalizeDouble((_entrada - GetStopLoss()), _Digits);
	              
	         			if (GetPrice().last >= _entrada && !HasPositionOpen()) {         
	         			   _wait = false;
	         				Buy(_entrada, _auxStopLoss, _auxStopGain, getRobotName());           				          
	         			}             		     		
         			
      		   	}
      		   	
						if(GetPrice().last < _eMALongValues[0]){
						
							if(GetPrice().last > _eMAShortValues[0]) return;
      		         		      		   
	      		      double _entrada = _minima + GetSpread();
	         			double _auxStopGain = NormalizeDouble((_entrada - GetStopGain()), _Digits);
	         			double _auxStopLoss = NormalizeDouble((_entrada + GetStopLoss()), _Digits);
	              
	         			if (GetPrice().last <= _entrada && !HasPositionOpen()) {         
	         			   _wait = false;
	         				Buy(_entrada, _auxStopLoss, _auxStopGain, getRobotName());           				          
	         			}             		     		
         			
      		   	}

				} 
				
			}  		
			
   		   
   	};
   	
      void ExecuteOnTrade(){
      
			BadRobot::ExecuteOnTradeBase();
         
      };
};

