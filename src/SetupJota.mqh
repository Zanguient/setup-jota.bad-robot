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
	
			int copiedMALongBuffer = CopyBuffer(_eMALongHandle, 0, 0, 5, _eMALongValues);
			int copiedMAShortBuffer = CopyBuffer(_eMAShortHandle, 0, 0, 5, _eMAShortValues);
			int copiedRates = CopyRates(GetSymbol(), GetPeriod(), 0, 50, _rates);
	
			return copiedRates > 0 && copiedMALongBuffer > 0 && copiedMAShortBuffer > 0;
	
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
   		   
   	};
   	
      void ExecuteOnTrade(){
      
            BadRobot::ExecuteOnTradeBase();
         
      };
};

