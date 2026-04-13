package controller.Main;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Arrays;
import java.util.Comparator;
import java.lang.reflect.Type;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import dao.pack.PackContentDAO;
import dao.pack.PackDAO;
import dao.player.PlayerDAO;
import dao.user.UserDAO;
import dao.player.OwnedPlayerDAO;
import dao.record.MatchRecordDAO;
import dao.pve.BattleSessionDAO;
import dao.pve.PveSubstageDAO;

import dto.mission.UserDailyMissionDTO;
import dto.pack.PackContentDTO;
import dto.pack.PackDTO;
import dto.player.PlayerDTO;
import dto.player.OwnedPlayerDTO;
import dto.user.UserDTO;
import dto.player.OwnedPlayerInfoDTO;
import dto.record.MatchRecordDTO;
import dto.record.PlayerRecordSummaryDTO;
import dto.pve.PveStageMapDTO;
import dto.pve.PveSubstageDTO;
import dto.pve.PveOpponentInfoDTO;
import dto.pve.BattleProgressDTO;
import dto.pve.BattleSessionDTO;
import dto.pve.BattleFighterDTO; // 3:3 시스템용 DTO

import service.gacha.GachaService;
import service.mission.DailyMissionService;
import service.user.LoginService;
import service.entry.PveEntryService;
import service.pve.PveScenarioService;
import service.pve.PveSubstageService;
import service.pve.PveBattleService; // 3:3 ATB 시뮬레이션 엔진

// ★ 주의: 구시대 시스템인 BuildService 관련 import 및 @Autowired는 완전히 제거했습니다.

@Controller
public class MainController {

    @Autowired private LoginService loginService;
    @Autowired private PackDAO packDAO;
    @Autowired private PackContentDAO packContentDAO;
    @Autowired private PlayerDAO playerDAO;
    @Autowired private GachaService gachaService;
    @Autowired private UserDAO userDAO;
    @Autowired private OwnedPlayerDAO ownedPlayerDAO;
    @Autowired private MatchRecordDAO matchRecordDAO;
    @Autowired private PveEntryService pveEntryService;
    @Autowired private PveScenarioService pveScenarioService;
    @Autowired private PveSubstageService pveSubstageService;
    @Autowired private BattleSessionDAO battleSessionDAO;
    @Autowired private PveSubstageDAO pveSubstageDAO;
    @Autowired private PveBattleService pveBattleService; // 3:3 신규 엔진
    @Autowired private DailyMissionService dailyMissionService;

    private final Random rand = new Random();
    private final Gson gson = new Gson();

    // ========================================
    // 1. 메인, 로그인, 로그아웃
    // ========================================
    @GetMapping("/")
    public String mainPage(HttpSession session) {
        if (session.getAttribute("loginUser") == null) return "redirect:/login";
        return "redirect:/mode-select";
    }

    @GetMapping("/mode-select")
    public String modeSelectPage(HttpSession session) {
        if (session.getAttribute("loginUser") == null) return "redirect:/login";
        return "modeSelect";
    }

    @GetMapping("/login")
    public String loginPage() {
        return "login";
    }

    @PostMapping("/login-process")
    public String loginProcess(@RequestParam("username") String userId,
                               @RequestParam("password") String userPw,
                               HttpSession session, RedirectAttributes rttr) {
        UserDTO userToLogin = new UserDTO();
        userToLogin.setUserId(userId);
        userToLogin.setUserPw(userPw);
        UserDTO loginUser = loginService.login(userToLogin, session);
        if (loginUser != null) {
            try {
                dailyMissionService.getUserMissionsToday(loginUser.getUserId());
            } catch (Exception e) {
                System.err.println("일일 미션 초기화 실패: " + e.getMessage());
            }
            return "redirect:/mode-select";
        } else {
            rttr.addFlashAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
            return "redirect:/login";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        loginService.logout(session);
        return "redirect:/login";
    }

    // ========================================
    // 2. 가챠 시스템
    // ========================================
    @GetMapping("/gacha")
    public String gachaPage(HttpSession session, Model model) {
        if (session.getAttribute("loginUser") == null) return "redirect:/login";

        List<PackDTO> packList = packDAO.selectAvailablePacks();
        model.addAttribute("packList", packList);

        Map<Integer, PackDTO> allPackDetails = new HashMap<>();
        Map<Integer, List<PlayerDTO>> allFeaturedPlayers = new HashMap<>();
        List<String> rarityOrder = Arrays.asList("UR", "SSR", "SR", "R", "N");

        if (packList != null && !packList.isEmpty()) {
            for (PackDTO packStub : packList) {
                int packSeq = packStub.getPackSeq();
                PackDTO fullPackData = packDAO.selectPackBySeq(packSeq);
                if (fullPackData != null) {
                    allPackDetails.put(packSeq, fullPackData);
                    List<PackContentDTO> contents = packContentDAO.selectPackContentsByPackSeq(packSeq);
                    List<PlayerDTO> featuredPlayers = getFeaturedPlayersFromContents(contents, 100);
                    featuredPlayers.sort(Comparator.comparingInt(player -> {
                        String rarity = (player.getRarity() == null) ? "N" : player.getRarity().toUpperCase();
                        int index = rarityOrder.indexOf(rarity);
                        return (index == -1) ? rarityOrder.size() : index;
                    }));
                    allFeaturedPlayers.put(packSeq, featuredPlayers);
                }
            }
            PackDTO defaultPack = allPackDetails.get(packList.get(0).getPackSeq());
            if (defaultPack != null) model.addAttribute("defaultSelectedPack", defaultPack);
            model.addAttribute("defaultFeaturedPlayers", allFeaturedPlayers.get(packList.get(0).getPackSeq()));
        }
        model.addAttribute("allPackDetailsJson", gson.toJson(allPackDetails));
        model.addAttribute("allFeaturedPlayersJson", gson.toJson(allFeaturedPlayers));
        return "gacha";
    }

    @PostMapping("/gacha/draw")
    @ResponseBody
    public Map<String, Object> drawPlayer(@RequestParam("packSeq") int packSeq, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { response.put("error", "not_logged_in"); return response; }
        try {
            PlayerDTO drawnPlayer = gachaService.drawSinglePlayer(loginUser.getUserId(), packSeq);
            if (drawnPlayer != null) {
                UserDTO updatedUser = userDAO.selectUserCurrency(loginUser.getUserId());
                loginUser.setCrystal(updatedUser.getCrystal());
                session.setAttribute("loginUser", loginUser);
                response.put("updatedCurrency", updatedUser);
                response.put("player", drawnPlayer);
                response.put("success", true);
                
                try {
                    dailyMissionService.incrementMissionProgress(loginUser.getUserId(), "GACHA", 1);
                } catch (Exception e) {
                    System.err.println("가챠 미션 업데이트 실패: " + e.getMessage());
                }
            } else {
                response.put("success", false);
                response.put("message", "재화가 부족하거나 오류가 발생했습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "뽑기 중 오류가 발생했습니다.");
        }
        return response;
    }

    // ========================================
    // 3. 선수단 보기
    // ========================================
    @GetMapping("/my-team")
    public String myTeamPage(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/login";
        try {
            List<OwnedPlayerInfoDTO> playerList = ownedPlayerDAO.selectOwnedPlayersByUserId(loginUser.getUserId());
            model.addAttribute("myPlayerList", playerList);
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("myPlayerList", new ArrayList<>());
            model.addAttribute("errorMessage", "선수 목록을 불러오는 데 실패했습니다.");
        }
        return "myTeam";
    }

    @GetMapping("/my-team/details")
    @ResponseBody
    public Map<String, Object> getPlayerDetailsAndRecords(@RequestParam("seq") int ownedPlayerSeq, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        if (session.getAttribute("loginUser") == null) { response.put("error", "not_logged_in"); return response; }
        try {
            OwnedPlayerInfoDTO playerDetails = ownedPlayerDAO.selectOwnedPlayerDetails(ownedPlayerSeq);
            if (playerDetails == null) { response.put("success", false); return response; }

            PlayerRecordSummaryDTO summary = matchRecordDAO.selectRecordSummary(ownedPlayerSeq);
            if (summary == null) summary = new PlayerRecordSummaryDTO();
            if (summary.getGamesPlayed() > 0) {
                double winRate = (double) summary.getWins() / summary.getGamesPlayed() * 100;
                summary.setWinRate(Math.round(winRate * 10.0) / 10.0);
            } else {
                summary.setWinRate(0.0);
            }
            List<MatchRecordDTO> recentMatches = matchRecordDAO.selectRecentMatches(ownedPlayerSeq, 10);
            if (recentMatches == null) recentMatches = new ArrayList<>();

            response.put("success", true);
            response.put("details", playerDetails);
            response.put("summary", summary);
            response.put("matches", recentMatches);
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "선수 정보를 불러오는 중 오류가 발생했습니다.");
        }
        return response;
    }

    @GetMapping("/player/details")
    @ResponseBody
    public Map<String, Object> getPlayerMasterDetails(@RequestParam("seq") int playerSeq, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        if (session.getAttribute("loginUser") == null) { response.put("error", "not_logged_in"); return response; }
        try {
            PlayerDTO playerDetails = playerDAO.selectPlayerBySeq(playerSeq);
            if (playerDetails != null) {
                response.put("success", true);
                response.put("details", playerDetails);
            } else {
                response.put("success", false);
                response.put("message", "선수 마스터 정보를 찾을 수 없습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "선수 정보를 불러오는 중 오류가 발생했습니다.");
        }
        return response;
    }

    // ========================================
    // 4. PVE 엔트리
    // ========================================
    @GetMapping("/my-team/entry")
    public String pveEntryPage(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/login";
        try {
            List<OwnedPlayerInfoDTO> allOwnedPlayers = ownedPlayerDAO.selectOwnedPlayersByUserId(loginUser.getUserId());
            model.addAttribute("allOwnedPlayers", allOwnedPlayers);
            List<OwnedPlayerInfoDTO> pveEntryPlayers = pveEntryService.getPveEntry(loginUser.getUserId());
            model.addAttribute("pveEntryPlayers", pveEntryPlayers);
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("errorMessage", "엔트리 정보를 불러오는 데 실패했습니다.");
            model.addAttribute("allOwnedPlayers", new ArrayList<>());
            model.addAttribute("pveEntryPlayers", new ArrayList<>());
        }
        return "pveEntry";
    }

    @PostMapping("/my-team/entry/save")
    @ResponseBody
    public Map<String, Object> savePveEntry(@RequestBody List<Integer> entryPlayerSeqList, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { response.put("error", "not_logged_in"); return response; }
        try {
            boolean success = pveEntryService.updatePveEntry(loginUser.getUserId(), entryPlayerSeqList);
            response.put("success", success);
            response.put("message", success ? "엔트리가 저장되었습니다." : "엔트리 저장에 실패했습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "엔트리 저장 중 오류가 발생했습니다.");
        }
        return response;
    }

    // ========================================
    // 5. PVE 로비 / 시나리오 / 스테이지
    // ========================================
    @GetMapping("/pve/lobby")
    public ModelAndView showPveLobbyPage(ModelAndView mv, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
        String userId = loginUser.getUserId();

        Map<Integer, String> stageStatusMap = pveScenarioService.getStageStatusMapForUser(userId);
        Integer maxStageFromDb = pveSubstageDAO.findMaxStageLevel();
        int maxStage = (maxStageFromDb != null && maxStageFromDb > 0) ? maxStageFromDb : 1;
        long clearedCount = stageStatusMap.values().stream().filter("CLEARED"::equals).count();

        Map<Integer, Double> stageProgressMap = new HashMap<>();
        for (Map.Entry<Integer, String> entry : stageStatusMap.entrySet()) {
            int stageLevel = entry.getKey();
            String status = entry.getValue();
            if ("CLEARED".equals(status)) {
                stageProgressMap.put(stageLevel, 100.0);
            } else if ("IN_PROGRESS".equals(status)) {
                try {
                    List<PveSubstageDTO> allSubs = pveSubstageDAO.findSubstagesByStageLevel(stageLevel);
                    int total = (allSubs != null) ? allSubs.size() : 0;
                    if (total > 0) {
                        Map<String, Object> params = new HashMap<>();
                        params.put("userId", userId);
                        params.put("stageLevel", stageLevel);
                        List<dto.pve.UserPveSubstageProgressDTO> cleared = pveSubstageDAO.findClearedSubstagesForUser(params);
                        int clearedSubs = (cleared != null) ? cleared.size() : 0;
                        double pct = Math.round((clearedSubs * 1000.0 / total)) / 10.0;
                        stageProgressMap.put(stageLevel, pct);
                    } else {
                        stageProgressMap.put(stageLevel, 0.0);
                    }
                } catch (Exception e) {
                    stageProgressMap.put(stageLevel, 0.0);
                }
            } else {
                stageProgressMap.put(stageLevel, 0.0);
            }
        }

        int playerCount = 0;
        try {
            List<OwnedPlayerInfoDTO> players = ownedPlayerDAO.selectOwnedPlayersByUserId(userId);
            playerCount = players != null ? players.size() : 0;
        } catch (Exception e) { /* 무시 */ }

        // ★ 구시대 빌드 시스템 관련 모델 데이터 제거

        dto.record.PlayerStatRankDTO mostPlayed  = null;
        dto.record.PlayerStatRankDTO bestWinRate = null;
        dto.record.PlayerStatRankDTO mostWins    = null;
        try {
            mostPlayed  = matchRecordDAO.selectMostPlayedPlayer(userId);
            bestWinRate = matchRecordDAO.selectBestWinRatePlayer(userId);
            mostWins    = matchRecordDAO.selectMostWinsPlayer(userId);
        } catch (Exception e) { /* 무시 */ }

        mv.addObject("stageStatusMap",   stageStatusMap);
        mv.addObject("stageProgressMap", stageProgressMap);
        mv.addObject("maxStageLevel",    maxStage);
        mv.addObject("clearedCount",     clearedCount);
        mv.addObject("totalStage",       maxStage);
        mv.addObject("playerCount",      playerCount);
        mv.addObject("mostPlayed",       mostPlayed);
        mv.addObject("bestWinRate",      bestWinRate);
        mv.addObject("mostWins",         mostWins);
        mv.setViewName("pveLobby");
        return mv;
    }


    @GetMapping("/pve/stage")
    public ModelAndView showPveStageDetailPage(@RequestParam("level") int level, ModelAndView mv, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
        String userId = loginUser.getUserId();
        Map<Integer, String> statusMap = pveScenarioService.getStageStatusMapForUser(userId);
        if (!"IN_PROGRESS".equals(statusMap.getOrDefault(level, "LOCKED"))) {
            mv.setViewName("redirect:/pve/lobby");
            return mv;
        }
        List<Map<String, Object>> subStages = pveSubstageService.getSubstageListWithStatus(userId, level);
        mv.addObject("mainStageLevel", level);
        mv.addObject("subStageList", subStages);
        mv.setViewName("pveStageDetail");
        return mv;
    }

    @GetMapping("/pve/stage/opponents")
    @ResponseBody
    public Map<String, Object> getOpponentsForRound(
            @RequestParam("level") int level,
            @RequestParam("subLevel") int subLevel,
            HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { result.put("error", "unauthorized"); return result; }
        try {
            List<PveOpponentInfoDTO> players = pveSubstageService.getOpponentEntryForSubstage(level, subLevel);
            String teamName = "AI Team";
            PveSubstageDTO details = pveSubstageService.getSubstageDetails(level, subLevel);
            if (details != null && details.getOpponentTeamName() != null) {
                teamName = details.getOpponentTeamName();
            }
            result.put("teamName", teamName);
            result.put("players", players != null ? players : new ArrayList<>());
        } catch (Exception e) {
            result.put("error", e.getMessage());
            result.put("players", new ArrayList<>());
        }
        return result;
    }

    // ========================================
    // 6. PVE 전투 준비
    // ========================================
    @GetMapping("/pve/battle")
    public ModelAndView showPveBattleSetupPage(@RequestParam("level") int stageLevel,
                                               @RequestParam("subLevel") int subLevel,
                                               ModelAndView mv, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
        String userId = loginUser.getUserId();

        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("stageLevel", stageLevel);
        params.put("subLevel", subLevel);

        BattleSessionDTO activeBattle = battleSessionDAO.selectActiveBattle(params);
        if (activeBattle != null) {
            mv.setViewName("redirect:/pve/battle/result?level=" + stageLevel + "&subLevel=" + subLevel);
            return mv;
        }

        try {
            List<Map<String, Object>> subStageList = pveSubstageService.getSubstageListWithStatus(userId, stageLevel);
            boolean isCleared = subStageList.stream()
                .anyMatch(s -> s.get("subLevel") != null
                    && Integer.parseInt(s.get("subLevel").toString()) == subLevel
                    && "CLEARED".equals(s.get("status")));
            if (isCleared) {
                mv.setViewName("redirect:/pve/stage?level=" + stageLevel);
                return mv;
            }
        } catch (Exception e) { /* 무시 */ }
        
        if (session.getAttribute("currentBattleId") != null) cleanUpPveSession(session);

        String myTeamName = (loginUser.getTeamName() != null) ? loginUser.getTeamName() : loginUser.getUserNick();
        PveSubstageDTO substageDetails = pveSubstageService.getSubstageDetails(stageLevel, subLevel);
        String opponentTeamName = (substageDetails != null) ? substageDetails.getOpponentTeamName() : "AI Team";

        List<PveStageMapDTO> mapList = pveSubstageService.getMapsForSubstage(stageLevel, subLevel);
        if (mapList == null) mapList = new ArrayList<>();
        List<OwnedPlayerInfoDTO> myEntryList = pveEntryService.getPveEntry(userId);
        if (myEntryList == null) myEntryList = new ArrayList<>();
        List<PveOpponentInfoDTO> opponentEntryList = pveSubstageService.getOpponentEntryForSubstage(stageLevel, subLevel);

        Map<Integer, PveOpponentInfoDTO> aiPlayerMap = new HashMap<>();
        if (opponentEntryList != null) {
            for (PveOpponentInfoDTO aiPlayer : opponentEntryList) {
                if (aiPlayer.getSetNumber() > 0) aiPlayerMap.put(aiPlayer.getSetNumber(), aiPlayer);
            }
        }

        mv.addObject("stageLevel", stageLevel);
        mv.addObject("subLevel", subLevel);
        mv.addObject("myTeamName", myTeamName);
        mv.addObject("opponentTeamName", opponentTeamName);
        mv.addObject("mapList", mapList);
        mv.addObject("myEntryList", myEntryList);
        mv.addObject("opponentEntryList", opponentEntryList);
        mv.addObject("aiPlayerMap", aiPlayerMap);
        mv.setViewName("pveMatchSetup");
        return mv;
    }

    // =====================================================
    // 훈련 시스템
    // =====================================================
    @GetMapping("/pve/train")
    public ModelAndView showTrainPage(ModelAndView mv, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
        UserDTO currency = userDAO.selectUserCurrency(loginUser.getUserId());
        int trainPoint = (currency != null) ? currency.getTrainPoint() : 0;
        mv.addObject("trainPoint", trainPoint);
        List<OwnedPlayerInfoDTO> players = ownedPlayerDAO.selectOwnedPlayersByUserId(loginUser.getUserId());
        mv.addObject("players", players != null ? players : new ArrayList<>());
        mv.setViewName("pveTrain");
        return mv;
    }

    @PostMapping("/pve/train/use")
    @ResponseBody
    public Map<String, Object> useTrainPoint(
            @RequestParam("ownedPlayerSeq") int ownedPlayerSeq,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { res.put("success", false); res.put("message", "로그인 필요"); return res; }

        String userId = loginUser.getUserId();
        UserDTO currency = userDAO.selectUserCurrency(userId);
        if (currency == null || currency.getTrainPoint() < 1) {
            res.put("success", false); res.put("message", "훈련 포인트가 부족합니다."); return res;
        }
        OwnedPlayerDTO player = ownedPlayerDAO.selectOwnedPlayer(ownedPlayerSeq);
        if (player == null || !userId.equals(player.getUserId())) {
            res.put("success", false); res.put("message", "선수를 찾을 수 없습니다."); return res;
        }

        Map<String, Object> tpParams = new HashMap<>();
        tpParams.put("userId", userId);
        tpParams.put("amount", -1);
        userDAO.updateUserTrainPoint(tpParams);

        // 변경된 DTO 메서드 적용
        int a  = player.getCurrentAttack()  == 0 ? 50 : player.getCurrentAttack();
        int d  = player.getCurrentDefense() == 0 ? 50 : player.getCurrentDefense();
        int hp = player.getCurrentHp()      == 0 ? 50 : player.getCurrentHp();
        int ha = player.getCurrentHarass()  == 0 ? 50 : player.getCurrentHarass();
        int s  = player.getCurrentSpeed()   == 0 ? 50 : player.getCurrentSpeed();

        int[] inc = new int[5];
        for (int i = 0; i < 3; i++) inc[rand.nextInt(5)]++;

        player.setCurrentAttack(a  + inc[0]);
        player.setCurrentDefense(d + inc[1]);
        player.setCurrentHp(hp     + inc[2]);
        player.setCurrentHarass(ha + inc[3]);
        player.setCurrentSpeed(s   + inc[4]);
        ownedPlayerDAO.updatePlayerStats(player);
        
        try {
            dailyMissionService.incrementMissionProgress(userId, "TRAIN", 1);
        } catch (Exception e) {
            System.err.println("훈련 미션 업데이트 실패: " + e.getMessage());
        }

        res.put("success", true);
        res.put("attackInc",  inc[0]); res.put("defenseInc", inc[1]);
        
        // JSON Key 변경 적용
        res.put("hpInc",      inc[2]); res.put("harassInc",  inc[3]); res.put("speedInc", inc[4]);
        res.put("afterAttack",  player.getCurrentAttack());
        res.put("afterDefense", player.getCurrentDefense());
        res.put("afterHp",      player.getCurrentHp());
        res.put("afterHarass",  player.getCurrentHarass());
        res.put("afterSpeed",   player.getCurrentSpeed());
        res.put("remainPoint",  currency.getTrainPoint() - 1);
        return res;
    }

    // ========================================
    // 8. 3:3 PVE 배틀 시뮬레이션
    // ========================================
    @PostMapping("/pve/battle/start")
    public ModelAndView startPveBattle(
            @RequestParam("level") int stageLevel,
            @RequestParam("subLevel") int subLevel,
            // ★ 3:3 시스템용 파라미터 (총 3명)
            @RequestParam("set1Player") int p1OwnedSeq,
            @RequestParam("set2Player") int p2OwnedSeq,
            @RequestParam("set3Player") int p3OwnedSeq,
            ModelAndView mv, HttpSession session) {

        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
        String userId = loginUser.getUserId();

        try {
            Map<String, Object> checkParams = new HashMap<>();
            checkParams.put("userId", userId);
            checkParams.put("stageLevel", stageLevel);
            checkParams.put("subLevel", subLevel);
            BattleSessionDTO existingBattle = battleSessionDAO.selectActiveBattle(checkParams);
            if (existingBattle != null) {
                mv.setViewName("redirect:/pve/battle/result?level=" + stageLevel + "&subLevel=" + subLevel);
                return mv;
            }
        } catch (Exception e) { }

        try {
            // DB에 세션 저장 (3:3은 단판 승부이므로 currentSet 등은 1로 고정)
            BattleSessionDTO newSession = new BattleSessionDTO();
            newSession.setUserId(userId);
            newSession.setStageLevel(stageLevel);
            newSession.setSubLevel(subLevel);
            // 선택한 3명의 ID를 저장 (나중에 Service에서 조회할 때 사용)
            String matchupData = String.format("[%d, %d, %d]", p1OwnedSeq, p2OwnedSeq, p3OwnedSeq);
            newSession.setMatchupData(matchupData); 
            newSession.setStatus("IN_PROGRESS");
            newSession.setCurrentSet(1);
            battleSessionDAO.insertNewBattle(newSession);

            session.setAttribute("currentBattleId", "DB_BATTLE_ACTIVE");
            mv.setViewName("redirect:/pve/battle/result?level=" + stageLevel + "&subLevel=" + subLevel);
        } catch (Exception e) {
            e.printStackTrace();
            mv.setViewName("redirect:/pve/lobby");
        }
        return mv;
    }

    @GetMapping("/pve/battle/result")
    public ModelAndView showPveBattleResult(@RequestParam("level") int stageLevel,
                                            @RequestParam("subLevel") int subLevel,
                                            ModelAndView mv, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
        String userId = loginUser.getUserId();
 
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("stageLevel", stageLevel);
        params.put("subLevel",   subLevel);
 
        BattleSessionDTO activeBattle = battleSessionDAO.selectActiveBattle(params);
        if (activeBattle == null) { mv.setViewName("redirect:/pve/lobby"); return mv; }
 
        // ★ 3:3 백엔드 시뮬레이션 실행 (결과를 0.1초 만에 계산)
        Map<String, Object> simResult = pveBattleService.runBattleSimulation(userId, stageLevel, subLevel);
 
        // 시뮬레이션 결과(초기 스탯 + 타임라인 이벤트)를 프론트(JSP)로 넘김
        String battleDataJson = gson.toJson(simResult.get("fighters"));
        String eventLogJson = gson.toJson(simResult.get("eventTimeline"));
 
        mv.addObject("battleDataJson", battleDataJson);
        mv.addObject("eventLogJson",   eventLogJson);            
        mv.addObject("simWinner",      simResult.get("winner")); 
 
        mv.addObject("stageLevel",  stageLevel);
        mv.addObject("subLevel",    subLevel);
        mv.addObject("myTeamName",  loginUser.getTeamName() != null ? loginUser.getTeamName() : loginUser.getUserNick());
 
        PveSubstageDTO substageDetails = pveSubstageService.getSubstageDetails(stageLevel, subLevel);
        mv.addObject("opponentTeamName", substageDetails != null ? substageDetails.getOpponentTeamName() : "AI Team");
 
        mv.setViewName("pveBattleSimulation");
        return mv;
    }

    @PostMapping("/pve/battle/finish")
    @ResponseBody
    public Map<String, Object> finishPveBattle(
            @RequestParam("level") int stageLevel,
            @RequestParam("subLevel") int subLevel,
            @RequestParam("winner") String winner, // "blue" (유저 승리) or "red" (패배)
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return response;
        }

        String userId = loginUser.getUserId();
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("stageLevel", stageLevel);
        params.put("subLevel", subLevel);

        BattleSessionDTO activeBattle = battleSessionDAO.selectActiveBattle(params);
        if (activeBattle == null) {
            response.put("success", false);
            response.put("message", "진행 중인 경기를 찾을 수 없습니다.");
            return response;
        }

        boolean finalVictory = "blue".equals(winner);

        // 3:3은 단판 승부이므로 즉시 결과를 DB에 반영
        if (finalVictory) {
            try {
                battleSessionDAO.completePveBattleSession(params);
                pveSubstageService.clearSubstage(userId, stageLevel, subLevel);
                response.put("message", "전투에서 승리했습니다! 스테이지가 클리어 되었습니다.");
                
                try {
                    dailyMissionService.incrementMissionProgress(userId, "PVE_WIN", 1);
                } catch (Exception e) {}
            } catch (Exception e) { e.printStackTrace(); }
        } else {
            battleSessionDAO.deletePveBattleSession(params);
            response.put("message", "전투에서 패배했습니다. 덱을 다시 짜서 도전하세요.");
        }
        
        response.put("success", true);
        response.put("victory", finalVictory);
        cleanUpPveSession(session);

        return response;
    }

    // ========================================
    // 강화 시스템
    // ========================================

    private int getEnhanceSuccessRate(int currentLevel) {
        if (currentLevel < 10) return 90;
        if (currentLevel < 20) return 80;
        if (currentLevel < 30) return 70;
        if (currentLevel < 40) return 60;
        if (currentLevel < 50) return 50;
        if (currentLevel < 60) return 35;
        if (currentLevel < 70) return 25;
        if (currentLevel < 80) return 15;
        if (currentLevel < 90) return 8;
        return 3; 
    }

    @GetMapping("/enhance")
    public String enhancePage(HttpSession session, org.springframework.ui.Model model) {
        if (session.getAttribute("loginUser") == null) return "redirect:/login";
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        List<OwnedPlayerInfoDTO> players = ownedPlayerDAO.selectOwnedPlayersByUserId(loginUser.getUserId());
        model.addAttribute("players", players);
        return "enhance";
    }

    @GetMapping("/enhance/info")
    @ResponseBody
    public Map<String, Object> getEnhanceInfo(@RequestParam("ownedPlayerSeq") int ownedPlayerSeq,
                                               HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { res.put("success", false); res.put("message", "로그인 필요"); return res; }

        OwnedPlayerDTO target = ownedPlayerDAO.selectOwnedPlayer(ownedPlayerSeq);
        if (target == null || !loginUser.getUserId().equals(target.getUserId())) {
            res.put("success", false); res.put("message", "선수를 찾을 수 없습니다."); return res;
        }

        List<OwnedPlayerDTO> materials = ownedPlayerDAO.selectMaterialCandidates(target);

        res.put("success", true);
        res.put("ownedPlayerSeq",  target.getOwnedPlayerSeq());
        res.put("enhanceLevel",    target.getEnhanceLevel());
        res.put("enhanceAttack",   target.getEnhanceAttack());
        res.put("enhanceDefense",  target.getEnhanceDefense());
        
        // 변경된 DTO 메서드 및 JSON Key 적용
        res.put("enhanceHp",       target.getEnhanceHp());
        res.put("enhanceHarass",   target.getEnhanceHarass());
        res.put("enhanceSpeed",    target.getEnhanceSpeed());
        
        res.put("enhanceStreak",   target.getEnhanceStreak());
        res.put("materialCount",   materials.size());
        res.put("successRate",     getEnhanceSuccessRate(target.getEnhanceLevel()));
        res.put("maxLevel",        99);
        return res;
    }

    @PostMapping("/enhance/execute")
    @ResponseBody
    public Map<String, Object> executeEnhance(@RequestParam("ownedPlayerSeq") int ownedPlayerSeq,
                                               HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { res.put("success", false); res.put("message", "로그인 필요"); return res; }
        String userId = loginUser.getUserId();

        OwnedPlayerDTO target = ownedPlayerDAO.selectOwnedPlayer(ownedPlayerSeq);
        if (target == null || !userId.equals(target.getUserId())) {
            res.put("success", false); res.put("message", "선수를 찾을 수 없습니다."); return res;
        }
        if (target.getEnhanceLevel() >= 99) {
            res.put("success", false); res.put("message", "이미 최대 강화 단계입니다. (+99)"); return res;
        }

        List<OwnedPlayerDTO> materials = ownedPlayerDAO.selectMaterialCandidates(target);
        if (materials.isEmpty()) {
            res.put("success", false); res.put("message", "재료 선수가 없습니다. 동일한 선수(같은 팩)가 1장 더 필요합니다."); return res;
        }

        OwnedPlayerDTO material = materials.get(0);
        try {
            ownedPlayerDAO.deleteOwnedPlayer(material.getOwnedPlayerSeq());
        } catch (Exception e) {
            res.put("success", false); res.put("message", "재료 소모 중 오류 발생: " + e.getMessage()); return res;
        }

        int successRate = getEnhanceSuccessRate(target.getEnhanceLevel());
        boolean success = rand.nextInt(100) < successRate;

        res.put("successRate", successRate);
        res.put("success", true);
        res.put("enhanced", success);

        if (success) {
            // statNames 배열 변경
            String[] statNames = {"attack", "defense", "hp", "harass", "speed"};
            int statIdx = rand.nextInt(5);
            String statName = statNames[statIdx];

            int newLevel = target.getEnhanceLevel() + 1;
            target.setEnhanceLevel(newLevel);
            
            // 변경된 Setter 적용
            switch (statIdx) {
                case 0: target.setEnhanceAttack(target.getEnhanceAttack()   + 1); break;
                case 1: target.setEnhanceDefense(target.getEnhanceDefense() + 1); break;
                case 2: target.setEnhanceHp(target.getEnhanceHp()           + 1); break;
                case 3: target.setEnhanceHarass(target.getEnhanceHarass()   + 1); break;
                case 4: target.setEnhanceSpeed(target.getEnhanceSpeed()     + 1); break;
            }
            ownedPlayerDAO.updateEnhanceStats(target);

            int prevStreak = target.getEnhanceStreak();
            int newStreak  = prevStreak > 0 ? prevStreak + 1 : 1;
            target.setEnhanceStreak(newStreak);
            ownedPlayerDAO.updateEnhanceStreak(target);

            try {
                dailyMissionService.incrementMissionProgress(userId, "ENHANCE", 1);
            } catch (Exception e) {
                System.err.println("강화 미션 업데이트 실패: " + e.getMessage());
            }

            res.put("newEnhanceLevel",   target.getEnhanceLevel());
            res.put("enhancedStat",      statName);
            res.put("enhanceAttack",     target.getEnhanceAttack());
            res.put("enhanceDefense",    target.getEnhanceDefense());
            
            // JSON Key 변경 적용
            res.put("enhanceHp",         target.getEnhanceHp());
            res.put("enhanceHarass",     target.getEnhanceHarass());
            res.put("enhanceSpeed",      target.getEnhanceSpeed());
            
            res.put("enhanceStreak",     newStreak);
            res.put("message",           "+" + newLevel + " 강화 성공! " + statName + " +1");
        } else {
            // ... (실패 처리 등 나머지 코드 동일) ...
            int prevStreak = target.getEnhanceStreak();
            int newStreak  = prevStreak < 0 ? prevStreak - 1 : -1;
            target.setEnhanceStreak(newStreak);
            ownedPlayerDAO.updateEnhanceStreak(target);

            res.put("newEnhanceLevel",  target.getEnhanceLevel());
            res.put("enhanceStreak",    newStreak);
            res.put("message",          "강화 실패. 재료만 소모되었습니다.");
        }

        res.put("remainMaterials", materials.size() - 1);
        res.put("nextSuccessRate", getEnhanceSuccessRate(target.getEnhanceLevel()));
        return res;
    }

    private void cleanUpPveSession(HttpSession session) {
        session.removeAttribute("currentBattleId");
        session.removeAttribute("setResults");
        session.removeAttribute("simulationMatchupList");
        session.removeAttribute("simulationMyTeamName");
        session.removeAttribute("simulationOpponentTeamName");
        session.removeAttribute("currentSet");
        session.removeAttribute("myWins");
        session.removeAttribute("aiWins");
        session.removeAttribute("currentGameState");
    }

    private List<PlayerDTO> getFeaturedPlayersFromContents(List<PackContentDTO> contents, int limit) {
        List<PlayerDTO> players = new ArrayList<>();
        if (contents != null && playerDAO != null) {
            int count = 0;
            for (PackContentDTO content : contents) {
                PlayerDTO player = playerDAO.selectPlayerBySeq(content.getPlayerSeq());
                if (player != null) {
                    players.add(player);
                    if (++count >= limit) break;
                }
            }
        }
        return players;
    }

    private int safeInt(Object val, int defaultVal) {
        if (val == null) return defaultVal;
        if (val instanceof Number) return ((Number) val).intValue();
        try { return Integer.parseInt(val.toString()); }
        catch (Exception e) { return defaultVal; }
    }
    
    // ========================================
    // 일일 미션 시스템
    // ========================================
    
    @GetMapping("/daily-missions")
    public String dailyMissionsPage(HttpSession session, Model model) {
        if (session.getAttribute("loginUser") == null) return "redirect:/login";
        
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        String userId = loginUser.getUserId();
        
        try {
            List<UserDailyMissionDTO> missions = dailyMissionService.getUserMissionsToday(userId);
            
            int totalMissions = missions.size();
            int completedMissions = (int) missions.stream().filter(m -> "Y".equals(m.getIsCompleted())).count();
            int claimedMissions = (int) missions.stream().filter(m -> "Y".equals(m.getIsClaimed())).count();
            int totalRewards = missions.stream()
                    .filter(m -> "Y".equals(m.getIsCompleted()) && "N".equals(m.getIsClaimed()))
                    .mapToInt(UserDailyMissionDTO::getRewardCrystal)
                    .sum();
            
            model.addAttribute("missions", missions);
            model.addAttribute("totalMissions", totalMissions);
            model.addAttribute("completedMissions", completedMissions);
            model.addAttribute("claimedMissions", claimedMissions);
            model.addAttribute("totalRewards", totalRewards);
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("missions", new ArrayList<>());
            model.addAttribute("errorMessage", "미션 정보를 불러오는 데 실패했습니다.");
        }
        
        return "dailyMissions";
    }
    
    @PostMapping("/daily-missions/claim")
    @ResponseBody
    public Map<String, Object> claimMissionReward(@RequestParam("missionId") int missionId, 
                                                   HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("success", false);
                result.put("message", "로그인이 필요합니다.");
                return result;
            }
            
            String userId = loginUser.getUserId();
            
            int rewardAmount = dailyMissionService.claimMissionReward(userId, missionId);
            
            UserDTO updatedUser = userDAO.selectUserCurrency(userId);
            session.setAttribute("loginUser", updatedUser);
            
            result.put("success", true);
            result.put("message", "보상을 수령했습니다!");
            result.put("rewardAmount", rewardAmount);
            result.put("newCrystal", updatedUser.getCrystal());
            
        } catch (IllegalStateException e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "보상 수령 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return result;
    }
    
    @PostMapping("/daily-missions/claim-all")
    @ResponseBody
    public Map<String, Object> claimAllRewards(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("success", false);
                result.put("message", "로그인이 필요합니다.");
                return result;
            }
            
            String userId = loginUser.getUserId();
            
            List<UserDailyMissionDTO> missions = dailyMissionService.getUserMissionsToday(userId);
            int totalReward = 0;
            int claimedCount = 0;
            
            for (UserDailyMissionDTO mission : missions) {
                if (mission.canClaim()) {
                    try {
                        int reward = dailyMissionService.claimMissionReward(userId, mission.getMissionId());
                        totalReward += reward;
                        claimedCount++;
                    } catch (Exception e) {
                        System.err.println("미션 " + mission.getMissionId() + " 수령 실패: " + e.getMessage());
                    }
                }
            }
            
            UserDTO updatedUser = userDAO.selectUserCurrency(userId);
            session.setAttribute("loginUser", updatedUser);
            
            result.put("success", true);
            result.put("message", claimedCount + "개의 보상을 수령했습니다!");
            result.put("claimedCount", claimedCount);
            result.put("totalReward", totalReward);
            result.put("newCrystal", updatedUser.getCrystal());
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "보상 수령 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return result;
    }
    
    @GetMapping("/daily-missions/claimable-count")
    @ResponseBody
    public Map<String, Object> getClaimableCount(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("count", 0);
                return result;
            }
            
            String userId = loginUser.getUserId();
            int count = dailyMissionService.getClaimableRewardCount(userId);
            
            result.put("count", count);
            
        } catch (Exception e) {
            result.put("count", 0);
            e.printStackTrace();
        }
        
        return result;
    }
}