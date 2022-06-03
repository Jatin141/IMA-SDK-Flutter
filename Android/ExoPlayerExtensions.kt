package com.gymfans

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Presentation
import android.content.Context
import android.content.pm.ActivityInfo
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.util.Log
import android.view.*
import android.view.WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
import android.widget.ImageView
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.ui.AspectRatioFrameLayout
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Util
import io.flutter.embedding.android.FlutterActivity

@SuppressLint("SourceLockedOrientationActivity")
fun ExoPlayer.preparePlayer(playerView: PlayerView, forceLandscape:Boolean = false,
                            mainActivity: com.gymfans.MainActivity,methodChannel: io.flutter.plugin.common.MethodChannel) {
    (playerView.context as Context).apply {
        val playerViewFullscreen = PlayerView(this)
        val layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        playerViewFullscreen.layoutParams = layoutParams
        playerViewFullscreen.visibility = View.GONE
        playerViewFullscreen.setBackgroundColor(Color.TRANSPARENT)
        (playerView.rootView as ViewGroup).apply { addView(playerViewFullscreen, childCount) }
        val fullScreenButton: ImageView = playerView.findViewById(R.id.exo_fullscreen_icon)
        val normalScreenButton: ImageView = playerViewFullscreen.findViewById(R.id.exo_fullscreen_icon)
        fullScreenButton.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_fullscreen_open))
        normalScreenButton.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_fullscreen_close))
        fullScreenButton.setOnClickListener {
         //   hideSystemUI(mainActivity)
            if (forceLandscape)
               mainActivity.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
            playerView.visibility = View.VISIBLE
            playerViewFullscreen.visibility = View.VISIBLE
            methodChannel.invokeMethod("fullScreen",0)
            PlayerView.switchTargetView(this@preparePlayer, playerView, playerViewFullscreen)
            playerView.resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT
            playerView.player = this@preparePlayer
        }
        normalScreenButton.setOnClickListener {
           // showSystemUI(mainActivity)
            if (forceLandscape)
                mainActivity.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
            normalScreenButton.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_fullscreen_close))
            playerView.visibility = View.VISIBLE
            playerViewFullscreen.visibility = View.GONE
            methodChannel.invokeMethod("normalScreen",0)
            PlayerView.switchTargetView(this@preparePlayer, playerViewFullscreen, playerView)
            playerView.resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT
            playerView.player = this@preparePlayer
        }
       // playerView.resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT
       // playerView.player = this@preparePlayer
    }
}

fun hideSystemUI(mainActivity: com.gymfans.MainActivity) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        mainActivity.window.setDecorFitsSystemWindows(true)
    } else {
        // hide status bar
        mainActivity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        mainActivity.window.decorView.systemUiVisibility =
            View.SYSTEM_UI_FLAG_IMMERSIVE or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
    }
//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
//        mainActivity.window.insetsController?.let {
//            // Default behavior is that if navigation bar is hidden, the system will "steal" touches
//            // and show it again upon user's touch. We just want the user to be able to show the
//            // navigation bar by swipe, touches are handled by custom code -> change system bar behavior.
//            // Alternative to deprecated SYSTEM_UI_FLAG_IMMERSIVE.
//            it.systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
//            // make navigation bar translucent (alternative to deprecated
//            // WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
//            // - do this already in hideSystemUI() so that the bar
//            // is translucent if user swipes it up
//         //   window.navigationBarColor = R.color.common_google_signin_btn_tint
//            // Finally, hide the system bars, alternative to View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
//            // and SYSTEM_UI_FLAG_FULLSCREEN.
//            it.hide(WindowInsets.Type.statusBars())
//        }
//    } else {
//        // Enables regular immersive mode.
//        // For "lean back" mode, remove SYSTEM_UI_FLAG_IMMERSIVE.
//        // Or for "sticky immersive," replace it with SYSTEM_UI_FLAG_IMMERSIVE_STICKY
//        @Suppress("DEPRECATION")
//        mainActivity.window.decorView.systemUiVisibility = (
//                // Do not let system steal touches for showing the navigation bar
//                View.SYSTEM_UI_FLAG_IMMERSIVE
//                        // Hide the nav bar and status bar
//                        or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION)
//        // make navbar translucent - do this already in hideSystemUI() so that the bar
//        // is translucent if user swipes it up
//      //  @Suppress("DEPRECATION")
//       // mainActivity.window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
//    }
}

fun showSystemUI(mainActivity: com.gymfans.MainActivity) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        mainActivity.window.setDecorFitsSystemWindows(false)
    } else {
        // Show status bar
       // mainActivity.window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
      //  mainActivity.window.decorView.systemUiVisibility =
       //     View.SYSTEM_UI_FLAG_IMMERSIVE or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
      //  mainActivity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        mainActivity.window.setStatusBarColor(Color.WHITE)
        mainActivity.window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_FULLSCREEN
    }

//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
//        // show app content in fullscreen, i. e. behind the bars when they are shown (alternative to
//        // deprecated View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION and View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)
//        mainActivity.window.setDecorFitsSystemWindows(false)
//        // finally, show the system bars
//        mainActivity.window.insetsController?.show(WindowInsets.Type.statusBars())
//    } else {
//        // Shows the system bars by removing all the flags
//        // except for the ones that make the content appear under the system bars.
//        @Suppress("DEPRECATION")
//        mainActivity.window.decorView.systemUiVisibility = (
//                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
//                        or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)
//    }
}
