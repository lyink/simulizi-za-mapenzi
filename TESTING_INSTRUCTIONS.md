# Testing Instructions - Simulizi za Mapenzi

## How to Test All Drawer Functionality

### Prerequisites
```bash
flutter run
```
Wait for app to fully load in emulator or device.

---

## Test 1: Theme Toggle (Dark Mode)

### Steps:
1. Open app drawer (swipe right or tap hamburger icon)
2. Locate "Dark Mode" toggle in **Design** section
3. Tap the switch or the entire row

### Expected Result:
- ✅ Background changes from cream to dark brown
- ✅ Text changes from dark to light cream
- ✅ Switch animates to ON position
- ✅ Icons become gold colored
- ✅ Transition is smooth

### Verify:
- Close and reopen drawer → Dark mode persists
- Navigate to other screens → Dark theme applies everywhere
- Close and restart app → Dark mode still enabled

---

## Test 2: Font Size Adjustment

### Steps:
1. Open app drawer
2. Tap "Font Size" (shows current: "Medium")
3. Dialog opens with 4 options
4. Select "Large"
5. Tap "Apply"

### Expected Result:
- ✅ All text in app immediately becomes larger
- ✅ Green snackbar shows: "Font size set to Large"
- ✅ Drawer subtitle updates to "Large"
- ✅ AppBar text is larger
- ✅ Menu items are larger
- ✅ Body text everywhere scales up

### Test All Sizes:
- **Small** (87.5%): Text is noticeably smaller
- **Medium** (100%): Default size (baseline)
- **Large** (112.5%): Text is bigger, easier to read
- **Extra Large** (125%): Maximum size for accessibility

### Verify:
- Open any screen → Font size applies
- Close and restart app → Font size persists
- Works in both light and dark modes

---

## Test 3: Color Scheme Selection

### Steps:
1. Open app drawer
2. Tap "Color Scheme" (shows current: "Default")
3. Dialog opens with 4 color options
4. Select "Blue"
5. Tap "Apply"

### Expected Result:
- ✅ AppBar turns blue immediately
- ✅ Green snackbar shows: "Color scheme set to Blue"
- ✅ Drawer subtitle updates to "Blue"
- ✅ All buttons turn blue
- ✅ Links and accents turn blue

### Test All Schemes:
- **Default (Brown)**: Original warm brown theme
- **Blue**: Cool blue professional look
- **Green**: Nature-inspired green theme
- **Purple**: Royal purple elegant theme

### What Changes:
- AppBar background color
- Primary buttons
- Text links
- Input field focus borders
- Selected menu items
- Progress indicators
- Tab indicators

### Verify:
- Open any screen → Color applies everywhere
- Tap buttons → Blue/Green/Purple accent
- Close and restart app → Color persists
- Works in both light and dark modes

---

## Test 4: Combination Testing

### Test A: Large Font + Blue Theme + Dark Mode
1. Set Font Size to "Large"
2. Set Color Scheme to "Blue"
3. Enable "Dark Mode"

**Expected**: Large text, blue accents, dark background

### Test B: Small Font + Purple Theme + Light Mode
1. Set Font Size to "Small"
2. Set Color Scheme to "Purple"
3. Disable "Dark Mode"

**Expected**: Compact text, purple accents, light background

### Test C: Extra Large + Green + Dark Mode
1. Set Font Size to "Extra Large"
2. Set Color Scheme to "Green"
3. Enable "Dark Mode"

**Expected**: Maximum text size, green accents, dark background

### Verify:
- All settings work together
- No conflicts or glitches
- Close app and reopen → All 3 settings persist
- Navigate to any screen → All settings apply

---

## Test 5: Other Drawer Items

### Navigation
- **Home**: ✅ Closes drawer
- **Categories**: ✅ Shows snackbar message
- **Search Stories**: ✅ Opens search dialog with input field

### Personal
- **Bookmarks**: ✅ Shows dialog with empty state icon
- **History**: ✅ Shows dialog with history icon
- **Favorites**: ✅ Shows dialog with favorites icon

### Premium
- **Unlock Premium**: ✅ Shows rewarded ad dialog with features list

### Management
- **Admin Panel**: ✅ Navigates to admin screen

### More
- **Notifications**: ✅ Opens notification preferences screen
- **Settings**: ✅ Opens settings dialog (may show ad first)
- **Help**: ✅ Shows help dialog with instructions
- **About**: ✅ Shows about dialog with app info and version

---

## Test 6: Persistence Test

### Steps:
1. Set Font Size to "Large"
2. Set Color Scheme to "Purple"
3. Enable Dark Mode
4. **Close the app completely** (swipe away from recent apps)
5. Reopen the app

### Expected Result:
- ✅ Font is still Large
- ✅ Theme is still Purple
- ✅ Dark Mode is still enabled
- ✅ All 3 settings remembered

### Explanation:
Settings are saved to SharedPreferences and load automatically on app start.

---

## Test 7: Visual Verification

### Font Size Visual Check:
```
Small:  This text is 87.5% of normal size
Medium: This text is 100% normal size
Large:  This text is 112.5% bigger
XLarge: This text is 125% biggest
```

### Color Scheme Visual Check:
Look at the AppBar color:
- Default: Brown (#8D4E27)
- Blue: Blue (#2196F3)
- Green: Green (#4CAF50)
- Purple: Purple (#9C27B0)

### Dark Mode Visual Check:
- Light Mode: Cream background, dark text
- Dark Mode: Dark brown background, cream text

---

## Test 8: Accessibility Test

### For Visually Impaired Users:
1. Set Font Size to "Extra Large"
2. Choose highest contrast color (Blue or Purple work well in Dark Mode)
3. Enable Dark Mode for reduced eye strain

### For Users with Color Blindness:
1. Try different color schemes
2. All schemes maintain good contrast
3. Text remains readable in all combinations

---

## Test 9: Performance Test

### Steps:
1. Change Font Size → Should be instant
2. Change Color Scheme → Should be instant
3. Toggle Dark Mode → Should animate smoothly
4. Navigate between screens → No lag
5. Open/close drawer → Smooth animation

### Expected:
- ✅ No frame drops
- ✅ Instant updates
- ✅ Smooth transitions
- ✅ No flickering
- ✅ Responsive UI

---

## Test 10: Edge Cases

### Test Rapid Changes:
1. Toggle Dark Mode on/off quickly 5 times
   - ✅ Should handle gracefully
2. Change font size rapidly
   - ✅ Should update correctly
3. Change color scheme rapidly
   - ✅ Should apply correctly

### Test Multiple Screens:
1. Change settings
2. Navigate to different screens:
   - Home screen
   - Admin panel
   - Notification preferences
   - Search dialog
   - Settings dialog
3. Verify settings apply to all screens

---

## Common Issues & Solutions

### Issue: Font size doesn't change
**Solution**: Make sure you tapped "Apply" button in dialog

### Issue: Color doesn't change
**Solution**: Make sure you tapped "Apply" button in dialog

### Issue: Settings don't persist
**Solution**: Check that app has permission to write to storage

### Issue: Dark mode glitchy
**Solution**: Hot restart the app with "R" command

### Issue: Some text doesn't scale
**Solution**: This is expected - only body text and UI elements scale

---

## Success Criteria

All tests pass if:
- ✅ Font size changes apply instantly and persist
- ✅ Color scheme changes apply instantly and persist
- ✅ Dark mode toggles smoothly and persists
- ✅ All three settings work together
- ✅ Settings persist after app restart
- ✅ All drawer menu items work
- ✅ No crashes or errors
- ✅ Smooth performance

---

## Reporting Issues

If you find any issues:
1. Note which test failed
2. Describe the expected vs actual behavior
3. Include steps to reproduce
4. Check logs for error messages

---

## Quick Test Checklist

- [ ] Dark Mode toggle works
- [ ] Font Size Small works
- [ ] Font Size Medium works
- [ ] Font Size Large works
- [ ] Font Size Extra Large works
- [ ] Color Scheme Default works
- [ ] Color Scheme Blue works
- [ ] Color Scheme Green works
- [ ] Color Scheme Purple works
- [ ] Settings persist after restart
- [ ] All drawer items are clickable
- [ ] No crashes or errors
- [ ] Performance is smooth

---

## Congratulations! 🎉

If all tests pass, your **Simulizi za Mapenzi** app has fully functional:
- ✅ Theme management
- ✅ Font size adjustment
- ✅ Color scheme selection
- ✅ Persistent settings
- ✅ Complete drawer functionality

**The app is ready for use!**
