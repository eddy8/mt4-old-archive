/* -*- coding: utf-8 -*-
 *
 * This script is licensed under GNU GENERAL PUBLIC LICENSE Version 3.
 * See a LICENSE file for detail of the license.
 */

#property copyright "Created by micclly, 2014"
#property link "https://github.com/micclly/mt4-scripts"

// Menu ID of Charts > Refresh
//
// This is possibly fixed and won't be changed in the future release of MT4,
// but if it's changed cange this value.
//
// Parameter inputs are useful to find menu ID programmatically.
// See the comments 2 lines below.
extern int MenuID_Refresh = 33324;

// Uncomment if input parameters
//#property show_inputs

// Input true, to find menu programmatically
extern bool FindMenu = false;

// If you set FindMenu to true, and your MT4 locale is not English,
// input correct menu name in your language.
extern string MenuName_Charts = "&Charts";
extern string MenuName_Refresh = "&Refresh";
// If your MT4 locale is Japanese, input as follows
// チャート (&C)
// 更新 (&R)


#include <WinUser32.mqh>

#import "user32.dll"
    int GetMenu(int hWnd);
    int GetSubMenu(int hMenu, int nPos);
    int GetMenuStringA(int hMenu, int itemId, string text, int maxTextCount, int flag);
    int GetMenuItemCount(int hMenu);
    int GetMenuItemID(int hMenu, int nPos);
    int GetParent(int hwnd);
#import

int getMT4Window(int currentChart)
{
    int mt4Window = 0;
    int parentWindow = GetParent(currentChart);
    int tmpHwnd = 0;
    while (true) {
        tmpHwnd = GetParent(parentWindow);
        if (tmpHwnd != 0) {
            parentWindow = tmpHwnd;
        } else {
            mt4Window = parentWindow;
            break;
        }
    }

    return(mt4Window);
}

int getChartsMenuPos(int menu)
{
    int i;
    string menuText = "a                   ";
    int menuCount = GetMenuItemCount(menu);
    int chartMenuPos = -1;

    for (i = 0; i < menuCount; i++) {
        GetMenuStringA(menu, i, menuText, 20, 0x400);
        if (menuText == MenuName_Charts) {
            chartMenuPos = i;
        }
    }

    return(chartMenuPos);
}

int getRefreshMenuID(int menu, int chartMenuPos)
{
    int chartMenu = GetSubMenu(menu, chartMenuPos);

    int i;
    string menuText = "a                   ";
    int chartMenuCount = GetMenuItemCount(chartMenu);
    int menuId = 0;
    int refreshMenuID = 0;

    for (i = 0; i < chartMenuCount; i++) {
        menuId = GetMenuItemID(chartMenu, i);
        GetMenuStringA(chartMenu, menuId, menuText, 20, 0);
        if (menuText == MenuName_Refresh) {
            refreshMenuID = menuId;
        }
    }

    return(refreshMenuID);
}

int start()
{
    if (!IsDllsAllowed()) {
        Alert("ERROR: DLL import is not allowed");
        return (0);
    }

    int currentChart = WindowHandle(Symbol(), Period());
    if (IsStopped()) {
        return(0);
    }

    int refreshMenuID = MenuID_Refresh;
    if (FindMenu) {
        int menu = GetMenu(getMT4Window(currentChart));
        int chartsMenuPos = getChartsMenuPos(menu);
        if (chartsMenuPos == -1) {
            Alert("ERROR: Menu[Charts] is not found");
            return(0);
        }

        refreshMenuID = getRefreshMenuID(menu, chartsMenuPos);
        if (refreshMenuID == 0) {
            Alert("ERROR: Menu[Charts > Refresh] is not found");
            return(0);
        }

        Print("Menu ID of [Charts > Refresh] is ", refreshMenuID);
    }

    if (PostMessageA(currentChart, WM_COMMAND, refreshMenuID, 0) != 0) {
        Print("Refreshed chart: ", Symbol(), ":", Period());
    } else {
        Alert("ERROR: Refresh chart failed: ", Symbol(), ":", Period());
    }
}
